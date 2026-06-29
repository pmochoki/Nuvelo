import { supabase, isSupabaseConfigured } from "./supabaseClient.js";

const BUCKET = "listing-images";
const MAX_BYTES = 5 * 1024 * 1024;
const ALLOWED = /^image\/(jpeg|jpg|png|webp|heic|heif)$/i;

/**
 * Upload a chat image (images only — no video).
 * @param {File} file
 * @param {string} threadId
 * @param {string} userId
 */
export async function uploadChatImage(file, threadId, userId) {
  if (!isSupabaseConfigured || !supabase) {
    throw new Error("Chat uploads are not configured.");
  }
  if (!(file instanceof File)) {
    throw new Error("Please choose a valid image file.");
  }
  if (!ALLOWED.test(file.type)) {
    throw new Error("Only JPG, PNG, or WebP images are allowed in chat.");
  }
  if (file.size > MAX_BYTES) {
    throw new Error("Image must be 5MB or smaller.");
  }
  const ext = file.type.includes("png") ? "png" : file.type.includes("webp") ? "webp" : "jpg";
  const path = `chat/${String(threadId).slice(0, 36)}/${String(userId).slice(0, 36)}-${Date.now()}.${ext}`;
  const { error } = await supabase.storage.from(BUCKET).upload(path, file, {
    cacheControl: "3600",
    upsert: false,
    contentType: file.type || "image/jpeg"
  });
  if (error) {
    console.error("[Nuvelo] chat image upload", error);
    throw new Error("Could not upload image. Try again.");
  }
  const { data: pub } = supabase.storage.from(BUCKET).getPublicUrl(path);
  return pub?.publicUrl || "";
}
