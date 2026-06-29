import { supabase, isSupabaseConfigured } from "./supabaseClient.js";

/**
 * @param {object} opts
 * @param {"listing" | "user"} opts.targetType
 * @param {string} opts.targetId
 * @param {string} [opts.reason]
 */
export async function submitModerationReport({ targetType, targetId, reason }) {
  if (!isSupabaseConfigured || !supabase) {
    throw new Error("Reporting is not configured.");
  }
  const tid = String(targetId || "").trim();
  if (!tid) {
    throw new Error("Missing report target.");
  }
  if (targetType !== "listing" && targetType !== "user") {
    throw new Error("Invalid report type.");
  }
  const {
    data: { user },
    error: userErr
  } = await supabase.auth.getUser();
  if (userErr || !user?.id) {
    throw new Error("Sign in to report this listing.");
  }

  let reporterLabel = user.email || "Member";
  const { data: profile } = await supabase
    .from("profiles")
    .select("display_name")
    .eq("id", user.id)
    .maybeSingle();
  if (profile?.display_name) {
    reporterLabel = String(profile.display_name);
  }

  const body = String(reason || "").trim() || "Reported from Nuvelo";

  const { error } = await supabase.from("moderation_reports").insert({
    reporter_user_id: user.id,
    reporter_label: reporterLabel.slice(0, 200),
    target_type: targetType,
    target_id: tid.slice(0, 500),
    reason: body.slice(0, 2000),
    status: "open"
  });

  if (error) {
    console.error("[Nuvelo] moderation_reports insert", error);
    throw new Error("Could not submit report. Try again.");
  }
}
