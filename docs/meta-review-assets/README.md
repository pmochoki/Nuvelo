# Meta App Review — demo video assets

Optional screen recording for **Reviewer instructions** (`documents-web-1`) when submitting Facebook Login (`email`, `public_profile`).

## Generate the video

From the repo root:

```bash
npm install
npx playwright install chromium
npm run record:meta-review
```

Output (not committed — large binary):

- `nuvelo-meta-app-review-demo.mp4` — upload this to Meta

The recording shows:

1. `https://nuvelo.one` homepage  
2. **Sign in** → auth modal  
3. **Continue with Facebook** → Facebook OAuth screen (proves integration; no password stored in the script)

## Upload in Meta

1. **App Review → Submissions** → open your draft  
2. **Reviewer instructions** tab  
3. Scroll to **(Optional) Include supporting documentation**  
4. Drag and drop `nuvelo-meta-app-review-demo.mp4`  
5. Save / continue submission  

Meta accepts `.mp4` and `.mov` (max 2 GB).

## Record manually (alternative)

If the script cannot reach Facebook (Unpublished app, network), record ~60 seconds with **QuickTime → New Screen Recording**:

1. Open Chrome → `https://nuvelo.one`  
2. Sign in → Continue with Facebook  
3. Show Facebook permission dialog (personal account)  
4. Return to nuvelo.one signed in  

Save as MP4 and upload to the same Meta field.
