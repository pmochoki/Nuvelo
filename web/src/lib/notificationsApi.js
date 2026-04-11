import { supabase, isSupabaseConfigured } from "./supabaseClient.js";

/**
 * @returns {Promise<Array<{ id: string, message: string, is_read: boolean, created_at: string }>>}
 */
export async function fetchNotificationsForCurrentUser() {
  if (!isSupabaseConfigured || !supabase) {
    return [];
  }
  const {
    data: { user },
    error: uerr
  } = await supabase.auth.getUser();
  if (uerr || !user?.id) {
    return [];
  }
  const { data, error } = await supabase
    .from("notifications")
    .select("id, message, is_read, created_at")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false })
    .limit(50);

  if (error) {
    console.error("[Nuvelo] notifications select", error);
    throw new Error("NOTIFICATIONS_LOAD_FAILED");
  }
  return data || [];
}
