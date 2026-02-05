I'm building a demo.

I'm going to use Flutter as a client: web and mobile.
It's going to use Firebase as a backend with new firebase functions support.
I'd like to integrate Genkit on the client and server.

## Goals

- easy to understandh
- visual interesting
- not a lot of set up for someone to clone and try out
- Demonstrates code sharing between client and server
- Demonstrates Genkit features


## Brainstorming discussion

- Think about caching in the cloud, too!!


### Ideas

#### 1. "Local Legend" (AI Scavenger Hunt)
*   **Concept:** The app generates a riddle based on the user's location or a general theme (e.g., "Find something that provides light but isn't a bulb"). User takes a photo of an object. AI confirms if it matches the riddle.
*   **Client (Flutter):** displaying riddles, camera interface, "success/fail" animations.
*   **Server (Firebase Functions + Genkit):**
    *   Generates riddles (Text generation).
    *   Validates photos (Vision model).
*   **Code Sharing:** `Riddle` class, `ValidationResult` class.
*   **Genkit Features:** Vision, Structured Output (JSON), Prompt Templates.

#### 2. "The Infinite Deck" (AI Card Battler)
*   **Concept:** Users enter a theme (e.g., "Space Cats"). AI generates a playable card with unique stats, abilities, and a generated image. Two cards can "battle" (simulated by code).
*   **Client (Flutter):** Card rendering (visuals), inputs for themes, battle animations.
*   **Server (Firebase Functions + Genkit):**
    *   Generates card metadata (stats/text) using JSON schema.
    *   Generates card art (Image generation).
*   **Code Sharing:** `Card` model, `Ability` enum, `BattleResult` model.
*   **Genkit Features:** Structured Output, Image Generation.

#### 3. "Emoji Chef" (Recipe Generator)
*   **Concept:** User selects 3 random emojis (e.g., 🥑🔥🍤). AI invents a creative recipe and generates a photo of the final dish.
*   **Client (Flutter):** Emoji picker, Recipe card display.
*   **Server (Firebase Functions + Genkit):**
    *   Interprets emojis to create a recipe (Text gen).
    *   Generates the dish image (Image gen).
*   **Code Sharing:** `Recipe` model, `Ingredient` class.
*   **Genkit Features:** Multimodal input (text/emoji logic), Image Generation.


