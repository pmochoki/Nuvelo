import { supabase, isSupabaseConfigured } from "./supabaseClient.js";

const BUCKET = "listing-images";
export const MAX_LISTING_PHOTOS = 12;
/** Accept large iPhone Pro Max originals; compress when the browser can decode the image. */
export const MAX_SOURCE_BYTES = 28 * 1024 * 1024;
const MAX_EDGE_PX = 2560;
const JPEG_QUALITY = 0.86;

function extFromMime(mime) {
  const m = String(mime || "").toLowerCase();
  if (m === "image/png") {
    return "png";
  }
  if (m === "image/webp") {
    return "webp";
  }
  return "jpg";
}

function formatMb(bytes) {
  return `${Math.round(bytes / (1024 * 1024))}MB`;
}

/**
 * Downscale JPEG/PNG/WebP in-browser. HEIC/HEIF uploads as-is when compression fails.
 * @param {File} file
 * @returns {Promise<File>}
 */
async function prepareListingImage(file) {
  if (!(file instanceof File) || !file.type.startsWith("image/")) {
    throw new Error("Please choose valid image files only.");
  }
  if (file.size > MAX_SOURCE_BYTES) {
    throw new Error(`Each photo must be ${formatMb(MAX_SOURCE_BYTES)} or smaller.`);
  }

  const canCompress = /image\/(jpeg|jpg|png|webp)/i.test(file.type);
  if (!canCompress || file.size < 1.5 * 1024 * 1024) {
    return file;
  }

  try {
    const bitmap = await createImageBitmap(file);
    const scale = Math.min(1, MAX_EDGE_PX / Math.max(bitmap.width, bitmap.height));
    const w = Math.max(1, Math.round(bitmap.width * scale));
    const h = Math.max(1, Math.round(bitmap.height * scale));
    const canvas = document.createElement("canvas");
    canvas.width = w;
    canvas.height = h;
    const ctx = canvas.getContext("2d");
    if (!ctx) {
      bitmap.close?.();
      return file;
    }
    ctx.drawImage(bitmap, 0, 0, w, h);
    bitmap.close?.();

    const blob = await new Promise((resolve, reject) => {
      canvas.toBlob(
        (b) => (b ? resolve(b) : reject(new Error("Could not compress image"))),
        "image/jpeg",
        JPEG_QUALITY
      );
    });

    if (blob.size >= file.size) {
      return file;
    }
    const base = file.name.replace(/\.[^.]+$/, "") || "photo";
    return new File([blob], `${base}.jpg`, { type: "image/jpeg", lastModified: Date.now() });
  } catch (err) {
    console.warn("[listing upload] compress skipped", err);
    return file;
  }
}

/**
 * @param {string} userId
 * @param {string} draftId
 * @param {File[]} files
 * @returns {Promise<string[]>}
 */
export async function uploadListingImages(userId, draftId, files) {
  if (!isSupabaseConfigured || !supabase) {
    throw new Error("Photo upload is not configured. Sign in and try again, or contact support.");
  }
  if (!userId) {
    throw new Error("Sign in to upload photos.");
  }
  const list = Array.from(files || []).filter((f) => f instanceof File);
  if (!list.length) {
    throw new Error("Add at least one photo.");
  }
  if (list.length > MAX_LISTING_PHOTOS) {
    throw new Error(`You can add up to ${MAX_LISTING_PHOTOS} photos.`);
  }

  const urls = [];
  for (let i = 0; i < list.length; i += 1) {
    const prepared = await prepareListingImage(list[i]);
    const ext = extFromMime(prepared.type);
    const path = `${userId}/${draftId}/${i + 1}-${Date.now()}.${ext}`;
    const { error } = await supabase.storage.from(BUCKET).upload(path, prepared, {
      upsert: false,
      contentType: prepared.type || "image/jpeg",
      cacheControl: "31536000"
    });
    if (error) {
      console.error("[listing upload]", error);
      throw new Error(
        "Could not upload a photo. Check your connection, or use a smaller image (under 28MB each)."
      );
    }
    const { data: pub } = supabase.storage.from(BUCKET).getPublicUrl(path);
    if (!pub?.publicUrl) {
      throw new Error("Photo uploaded but URL could not be resolved.");
    }
    urls.push(pub.publicUrl);
  }
  return urls;
}
