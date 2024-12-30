# Lyrical 🎶  

Lyrical is an innovative web application built with Flutter that generates lyrics based on user preferences using the powerful Gemini API. Whether you're a songwriter, poet, or just someone looking for fun, Lyrical helps you create custom lyrics tailored to your input.

---

## Table of Contents

1. [Features](#features)
2. [Modules and Working](#modules-and-working)
    * [User Input and Preferences](#user-input-and-preferences)
    * [Lyrics Generation](#lyrics-generation)
    * [Lyrics Refinement](#lyrics-refinement)
3. [Installation](#installation)
4. [Usage](#usage)
5. [API Server](#api-server)

---

## Features  

- **Custom Lyrics Generation**: Generate personalized lyrics by providing your preferences (e.g., theme, mood, or style).  
- **Real-Time Processing**: Experience quick lyric generation with minimal wait times.  
- **Responsive Design**: Enjoy seamless functionality across mobile, desktop, and web platforms.  
- **User-Friendly Interface**: Navigate effortlessly with a design built for beginners and experts alike.  

---

## Modules and Working  

### User Input and Preferences  

- Users provide inputs such as mood, style, or theme for lyrics generation.  
- The application validates user preferences to ensure a smooth experience.  

### Lyrics Generation  

- Inputs are processed using the Gemini API to create unique lyrics.  
- The results are displayed in an easy-to-read format, allowing users to refine their input and regenerate if needed.  

### Lyrics Refinement  

- Not satisfied with the first 3 versions? Click "Refine Lyrics" to generate more variations.  
- The results are displayed in an easy-to-read format, keeping ease of use as a primary concern.  

---

## Installation  

1. **Clone the Repository**:  

    ```bash
    git clone https://github.com/Duality404/Lyrical.git
    cd Lyrical
    ```

2. **Install Dependencies**:  

    ```bash
    flutter pub get
    ```

---

## Usage  

1. **Run the Application**:  

    ```bash
    flutter run -d chrome
    ```

2. **Interact with the App**:  

    - Enter preferences like mood, style, or theme.  
    - Click "Generate Lyrics" to create custom lyrics.  
    - Click "Refine Lyrics" to refine the existing generated lyrics.  

---

## API Server  

The Flask server handling API requests for Lyrical is hosted on **Vercel**.  
You can access the server's source code:  
**[Lyrical Flask Repository](https://github.com/Duality404/lyrical-flask)**  

This server communicates with the Gemini API to process user inputs and return generated lyrics.  
