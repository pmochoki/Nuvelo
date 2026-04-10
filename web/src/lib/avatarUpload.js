import { supabase, isSupabaseConfigured } from "./supabaseClient.js";

const MAX_BYTES = 5 * 1024 * 1024;
const BUCKET = "avatars";

/**
 * @param {string} mime
 */
function extFromMime(mime) {
  const m = String(mime || "").toLowerCase();
  if (m === "image/jpeg" || m === "image/jpg") {
    return "jpg";
  }
  if (m === "image/png") {
    return "png";
  }
  if (m === "image/webp") {
    return "webp";
  }
  if (m === "image/gif") {
    return "gif";
  }
  return "jpg";
}

/**
 * Upload avatar to Supabase Storage and persist URL on public.profiles.
 * @param {string} userId
 * @param {File} file
 * @returns {Promise<string>} public URL
 */
export async function uploadUserAvatarToSupabase(userId, file) {
  if (!isSupabaseConfigured || !supabase) {
    throw new Error("Storage is not configured.");
  }
  if (!userId || !(file instanceof File) || !file.type.startsWith("image/")) {
    throw new Error("Please choose a valid image.");
  }
  if (file.size > MAX_BYTES) {
    throw new Error("Image must be 5MB or smaller.");
  }

  const ext = extFromMime(file.type);
  const path = `${userId}/avatar.${ext}`;

  const { error: upErr } = await supabase.storage.from(BUCKET).upload(path, file, {
    upsert: true,
    contentType: file.type || "image/jpeg",
    cacheControl: "3600"
  });

  if (upErr) {
    console.error("[avatar upload]", upErr);
    throw new Error("Could not upload photo. Check that the avatars bucket exists and policies allow your account.");
  }

  const { data: pub } = supabase.storage.from(BUCKET).getPublicUrl(path);
  const url = pub?.publicUrl;
  if (!url) {
    throw new Error("Could not resolve photo URL.");
  }

  const { error: profErr } = await supabase.from("profiles").upsert(
    { id: userId, avatar_url: url },
    { onConflict: "id" }
  );

  if (profErr) {
    console.error("[profiles avatar_url]", profErr);
    throw new Error("Photo uploaded but profile could not be updated.");
  }

  return url;
}
