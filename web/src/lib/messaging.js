import { supabase, isSupabaseConfigured } from "./supabaseClient.js";

/** @param {unknown} s */
export function isUuid(s) {
  return (
    typeof s === "string" &&
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(s)
  );
}

/**
 * @param {string} a
 * @param {string} b
 */
export function orderedParticipants(a, b) {
  return a < b ? { low: a, high: b } : { low: b, high: a };
}

/**
 * @param {object} row
 * @param {string} uid
 */
export function otherUserIdFromThread(row, uid) {
  return row.participant_low === uid ? row.participant_high : row.participant_low;
}

/**
 * @param {object} opts
 * @param {string} opts.listingId
 * @param {string} opts.listingOwnerId
 * @param {string} [opts.listingTitle]
 * @param {string} [opts.listingThumbUrl]
 * @returns {Promise<string>} thread id
 */
export async function getOrCreateThread({ listingId, listingOwnerId, listingTitle, listingThumbUrl }) {
  if (!isSupabaseConfigured || !supabase) {
    throw new Error("Messaging is not configured.");
  }
  const {
    data: { user },
    error: userErr
  } = await supabase.auth.getUser();
  if (userErr || !user?.id) {
    throw new Error("Sign in to start a chat.");
  }
  const me = user.id;
  if (!isUuid(listingOwnerId)) {
    throw new Error("This listing uses a demo seller account. Chat works when both users are registered.");
  }
  if (me === listingOwnerId) {
    throw new Error("You cannot message yourself.");
  }
  const { low, high } = orderedParticipants(me, listingOwnerId);
  const lid = String(listingId);

  const { data: existing, error: selErr } = await supabase
    .from("message_threads")
    .select("id")
    .eq("listing_id", lid)
    .eq("participant_low", low)
    .eq("participant_high", high)
    .maybeSingle();

  if (selErr) {
    throw new Error(selErr.message || "Could not open chat.");
  }
  if (existing?.id) {
    return existing.id;
  }

  const { data: inserted, error: insErr } = await supabase
    .from("message_threads")
    .insert({
      listing_id: lid,
      listing_owner_id: listingOwnerId,
      participant_low: low,
      participant_high: high,
      listing_title_snapshot: listingTitle ? String(listingTitle).slice(0, 500) : "",
      listing_thumb_url: listingThumbUrl || null
    })
    .select("id")
    .single();

  if (insErr) {
    if (insErr.code === "23505") {
      const { data: retry } = await supabase
        .from("message_threads")
        .select("id")
        .eq("listing_id", lid)
        .eq("participant_low", low)
        .eq("participant_high", high)
        .maybeSingle();
      if (retry?.id) {
        return retry.id;
      }
    }
    throw new Error(insErr.message || "Could not create chat.");
  }
  return inserted.id;
}

/**
 * @returns {Promise<Array<object>>}
 */
export async function fetchThreadsForCurrentUser() {
  if (!isSupabaseConfigured || !supabase) {
    return [];
  }
  const {
    data: { user }
  } = await supabase.auth.getUser();
  if (!user?.id) {
    return [];
  }
  const uid = user.id;

  const { data: rows, error } = await supabase
    .from("message_threads")
    .select(
      "id, listing_id, listing_owner_id, participant_low, participant_high, listing_title_snapshot, listing_thumb_url, last_message_at, last_message_preview, last_message_from, created_at, updated_at"
    )
    .or(`participant_low.eq.${uid},participant_high.eq.${uid}`);

  if (error) {
    console.error("[messaging] list threads", error);
    throw new Error(error.message || "Could not load conversations.");
  }

  const list = (rows || []).sort((a, b) => {
    const ta = new Date(a.last_message_at || a.updated_at || 0).getTime();
    const tb = new Date(b.last_message_at || b.updated_at || 0).getTime();
    return tb - ta;
  });
  const otherIds = [...new Set(list.map((r) => otherUserIdFromThread(r, uid)))];
  let profileMap = new Map();
  if (otherIds.length > 0) {
    const { data: profiles } = await supabase
      .from("profiles")
      .select("id, display_name, avatar_url")
      .in("id", otherIds);
    for (const p of profiles || []) {
      profileMap.set(p.id, p);
    }
  }

  return list.map((row) => {
    const otherId = otherUserIdFromThread(row, uid);
    const prof = profileMap.get(otherId);
    const unread = row.last_message_from && row.last_message_from !== uid ? 1 : 0;
    return {
      ...row,
      otherUserId: otherId,
      otherDisplayName: prof?.display_name || "Member",
      otherAvatarUrl: prof?.avatar_url || "",
      unread,
      preview: row.last_message_preview || "No messages yet",
      dateLabel: formatShortDate(row.last_message_at || row.updated_at)
    };
  });
}

/**
 * @param {string} iso
 */
function formatShortDate(iso) {
  if (!iso) {
    return "—";
  }
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) {
    return "—";
  }
  return d.toLocaleString(undefined, {
    month: "short",
    day: "numeric",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit"
  });
}

/**
 * @param {string} threadId
 * @returns {Promise<Array<{ id: string, sender_id: string, body: string, created_at: string }>>}
 */
export async function fetchMessages(threadId) {
  if (!isSupabaseConfigured || !supabase) {
    return [];
  }
  const { data, error } = await supabase
    .from("messages")
    .select("id, sender_id, body, created_at")
    .eq("thread_id", threadId)
    .order("created_at", { ascending: true });

  if (error) {
    console.error("[messaging] messages", error);
    throw new Error(error.message || "Could not load messages.");
  }
  return data || [];
}

/**
 * @param {string} threadId
 * @param {string} body
 */
export async function sendMessage(threadId, body) {
  if (!isSupabaseConfigured || !supabase) {
    throw new Error("Messaging is not configured.");
  }
  const text = String(body || "").trim();
  if (!text) {
    throw new Error("Message cannot be empty.");
  }
  const {
    data: { user },
    error: uerr
  } = await supabase.auth.getUser();
  if (uerr || !user?.id) {
    throw new Error("Sign in to send a message.");
  }
  const { error } = await supabase.from("messages").insert({
    thread_id: threadId,
    sender_id: user.id,
    body: text
  });
  if (error) {
    throw new Error(error.message || "Could not send.");
  }
}

/**
 * Approximate unread thread count for nav badge (last message from other user).
 */
export async function fetchUnreadThreadCount() {
  if (!isSupabaseConfigured || !supabase) {
    return 0;
  }
  const {
    data: { user }
  } = await supabase.auth.getUser();
  if (!user?.id) {
    return 0;
  }
  const uid = user.id;
  const { data: rows, error } = await supabase
    .from("message_threads")
    .select("last_message_from")
    .or(`participant_low.eq.${uid},participant_high.eq.${uid}`);

  if (error) {
    return 0;
  }
  let n = 0;
  for (const r of rows || []) {
    if (r.last_message_from && r.last_message_from !== uid) {
      n += 1;
    }
  }
  return n;
}

/**
 * Subscribe to new messages in a thread (requires replication on `messages` in Supabase).
 * @param {string} threadId
 * @param {(row: object) => void} onInsert
 * @returns {() => void} unsubscribe
 */
export function subscribeToThreadMessages(threadId, onInsert) {
  if (!isSupabaseConfigured || !supabase) {
    return () => {};
  }
  const channel = supabase
    .channel(`messages:${threadId}`)
    .on(
      "postgres_changes",
      {
        event: "INSERT",
        schema: "public",
        table: "messages",
        filter: `thread_id=eq.${threadId}`
      },
      (payload) => {
        if (payload.new) {
          onInsert(payload.new);
        }
      }
    )
    .subscribe();

  return () => {
    void supabase.removeChannel(channel);
  };
}
