# 🎮 DualSense Expressive (`dualsensectl-gui` v2.0)

[![Platform](https://img.shields.io/badge/Platform-Linux%20%28Wayland%20%2F%20X11%29-blue.svg)](https://kernel.org)
[![Language](https://img.shields.io/badge/Language-C%2B%2B20-blue.svg)](https://en.cppreference.com/w/cpp/20)
[![Qt](https://img.shields.io/badge/GUI-Qt6%20QML%20(SceneGraph)-41CD52.svg)](https://qt.io)
[![Design](https://img.shields.io/badge/Design-Material%203%20Expressive-purple.svg)](https://m3.material.io)
[![Backend](https://img.shields.io/badge/Backend-dualsensectl%20v0.7.0-purple.svg)](https://github.com/nowrep/dualsensectl)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> Un gestionnaire de bureau ultra-moderne, fluide et natif sous Linux pour les manettes **Sony PlayStation 5 DualSense** et **DualSense Edge**, conçu selon les principes du design system **Material 3 Expressive** et réécrit en **C++20 & Qt6 / QML**.  
> Offre un contrôle granulaire en temps réel des gâchettes adaptatives, du bandeau lumineux RGB, de la batterie, du routage audio et du microphone matériel via [`dualsensectl`](https://github.com/nowrep/dualsensectl).

---

## 🎨 Design System : Material 3 Expressive

### 🌟 Expérience Visuelle & Micro-Interactions
- **Palette Dark Gaming OLED :** Fond noir profond (`#0B0D13`), conteneurs de surfaces hiérarchisés (`surfaceContainerLowest` à `surfaceContainerHighest`), et contrastes optimisés pour les configurations de jeu.
- **Effets de Lueur Ambiante (Dynamic Ambient Glows) :** Le halo d'ambiance projeté derrière la manette et les cartes réagit dynamiquement en temps réel à la couleur et à la luminosité émise par la Lightbar de la DualSense.
- **Formes & Contours Expressifs :** Boutons et chips pilules (`radius: 9999`), cartes aux angles prononcés (`radius: 28px`), jauges de batterie galbées et curseurs avec bulles flottantes de valeur numérique.
- **Micro-Interactions Élastiques :** Transitions avec courbes d'amortissement (`Easing.OutBack` / `Easing.OutCubic`) sur le survol, la pression des boutons et l'ajustement des gâchettes.

### 🕹 Visualiseur Interactif DualSense
- **Modèle Vectoriel Réactif en Direct :**
  - **Ailes Touchpad RGB :** S'illuminent instantanément avec la couleur et la luminosité définies.
  - **LEDs Joueur (1 à 5) :** Indicateurs sous le pavé tactile synchronisés avec le numéro de joueur sélectionné.
  - **LED Muet (Mute) :** S'allume en ambre PlayStation officiel lorsque le micro est coupé.
  - **Gâchettes L2 / R2 :** Mise en surbrillance lors du test ou de l'ajustement des gâchettes adaptatives.

### 📈 Graphique d'Onde des Gâchettes Adaptatives
- **Visualiseur Dynamique Force / Déplacement :** Trace en temps réel la courbe de résistance mécanique en fonction du mode sélectionné (cran de tir d'arme à feu, tension élastique d'arc, pulsation de mitrailleuse, battement de galop, mur de résistance ferme) avec curseur animé de pression de doigt.

---

## ⚡ Fonctionnalités Clés

1. **Tableau de Bord Central (Dashboard) :**
   - Vue d'ensemble du contrôleur avec jauge de batterie animée en temps réel et statut de charge.
   - Badge d'état de connexion (`Bluetooth` ou `USB` avec chemin `/dev/hidraw*`).
   - Raccourcis instantanés : 1-clic Mute micro, réglage rapide du volume, extinction Bluetooth.
   - Informations de firmware matériel (`Firmware version`, `Build number`).

2. **Studio des Gâchettes Adaptatives (Adaptive Triggers) :**
   - Ciblage au choix : Gâchette gauche (L2), Gâchette droite (R2) ou Les Deux (L2 + R2).
   - Préréglages gaming immédiats : *Pistolet Semi-Auto, Fusil à pompe lourd, Sniper, Arc composé, Mitrailleuse, Galop, Vibration moteur*.
   - **Support complet des 7 modes `dualsensectl` :**
     - `off` : Gâchette libre standard.
     - `feedback` : Mur de résistance à position et force définies.
     - `weapon` : Emulation de détente d'arme à feu (course, résistance et décrochage net).
     - `bow` : Tension progressive de corde d'arc avec force de relâchement (snap).
     - `machine` : Rafale alternée entre deux forces à fréquence et période réglables.
     - `galloping` : Rythme de galop à deux battements.
     - `vibration` : Oscillation haptique de gâchette autour d'une position centrale.

3. **Studio d'Éclairage RGB & LEDs Joueur :**
   - **Roue Chromatique HSV Haute Performance :** Rendu Canvas avec sélecteur circulaire teinte / saturation.
   - **Saisie Directe HEX :** Aperçu numérique direct du code couleur (`#388BFF`, etc.).
   - **Palettes Officielles Sony DualSense :** *Bleu PS5, Cyan Néon, Rouge Cosmique, Rose Nova, Violet Galactique, Blanc Astro, Vert Émeraude, Ambre Furtif*.
   - **Curseur de Luminosité globale (0-255).**
   - **Sélecteur de LEDs Joueur (0 à 5 LEDs) et Atténuation (Lumineux, Moyen, Atténué).**

4. **Contrôle Audio, Microphone & Haptique :**
   - Carte expressive dédiée pour couper / réactiver le microphone matériel d'un clic.
   - Comportement de la LED orange du micro (`on`, `off`, `pulse`).
   - Mode d'usage du micro (`chat`, `asr`, `both`).
   - Routage audio (`headphone`, `internal`, `both`) et curseur de volume maître (0-255).
   - **Atténuation du retour haptique (0-7) :** Permet d'atténuer indépendamment les moteurs de rumble voice-coil et les vibrations des gâchettes.

5. **Gestionnaire de Profils de Jeu (1-Clic) :**
   - Profils préconfigurés :
     - 🎯 **Competitive FPS** (Détente sèche, recul atténué pour la visée, micro coupé, rouge sang).
     - 🏎 **Sim Racing Pro** (Frein dur sur L2, tension d'accélérateur élastique sur R2, bleu néon).
     - 🏹 **RPG Hunter & Bow** (Corde d'arc lourde avec snap sec, vert émeraude).
     - 💥 **Heavy Gunner** (Mitrailleuse continue, haptique plein régime, ambre).
     - 🎬 **Cinematic Immersion** (Gâchettes douces, bandeau violet cosmique, casque).
     - 🔋 **Stealth Battery Saver** (LEDs coupées, haptique minimale pour longue autonomie).
   - Enregistrement en 1 clic de la configuration actuelle sous un nouveau profil.

6. **Simulateur Matériel Intégré (Mode Démo) :**
   - Permet d'explorer et de tester immédiatement toutes les fonctionnalités de l'interface même sans manette branchée ou sans daemon en cours. Bascule automatiquement en mode matériel dès qu'une DualSense physique est connectée !

7. **Intégration Plateau Système (System Tray / FreeDesktop) :**
   - Icône dans la barre des tâches avec niveau de batterie en infobulle.
   - Menu contextuel rapide : Mute micro, couleurs RGB rapides, profils, extinction Bluetooth, afficher/masquer.

---

## 🏗 Architecture Logicielle

```
dualsensectl-gui / DualSense Expressive
├── CMakeLists.txt                 # Configuration de compilation CMake (C++20, Qt6)
├── src/
│   ├── main.cpp                   # Point d'entrée Qt Quick, Enregistrement des types C++
│   ├── SystrayManager.cpp/.h      # Intégration System Tray Linux (SNI / FreeDesktop)
│   └── core/
│       ├── DualSenseDevice.cpp/.h # Modèle de données QObject exposé à QML
│       ├── DualSenseClient.cpp/.h # Backend IPC dualsensectl & Mode Simulation
│       └── ProfileManager.cpp/.h  # Gestionnaire de profils JSON
├── ui/
│   ├── App.qml                    # Fenêtre principale, barre de navigation, aura lumineuse
│   ├── theme/
│   │   └── ExpressiveTokens.qml   # Tokens de design Material 3 Expressive
│   ├── components/
│   │   ├── ExpressiveButton.qml   # Boutons pilules avec rebond élastique
│   │   ├── ExpressiveCard.qml     # Cartes avec halo de lueur ambiante
│   │   ├── ExpressiveSlider.qml   # Sliders galbés avec bulle numérique
│   │   ├── ExpressiveSwitch.qml   # Interrupteurs M3 à pastille mobile
│   │   ├── ExpressiveChip.qml     # Chips filtrants et sélecteurs
│   │   ├── StatusBadge.qml        # Badges d'état avec pulsation
│   │   ├── ColorWheel.qml         # Roue chromatique HSV Canvas temps réel
│   │   ├── InteractiveDualSense.qml # Manette vectorielle réactive (Lightbar, LEDs, Mute)
│   │   ├── TriggerVisualizer.qml  # Graphique de force des gâchettes
│   │   ├── ExpressiveFAB.qml      # Bouton flottant extensible
│   │   └── NotificationToast.qml  # Toast snackbar de notification
│   └── views/
│       ├── DashboardView.qml      # Tableau de bord principal
│       ├── TriggersView.qml       # Studio des gâchettes adaptatives
│       ├── LightingView.qml       # Studio d'éclairage RGB & LEDs
│       ├── AudioView.qml          # Gestion audio, micro et atténuation
│       └── ProfilesView.qml       # Gestionnaire de profils
├── resources/
│   ├── qml.qrc                    # Bundle des ressources QML et SVG
│   └── icons/
│       ├── app-icon.svg           # Icône d'application Material 3 Expressive
│       └── dualsense.svg          # Icône vectorielle manette
└── scripts/
    ├── build.sh                   # Script de compilation automatisé
    ├── run.sh                     # Lanceur de l'application
    ├── install_desktop.sh         # Installeur d'entrée de bureau (.desktop)
    └── setup_udev_rules.sh        # Règles udev pour l'accès hidraw sans root
```

---

## 🚀 Installation & Lancement

### 1. Prérequis
Sur Arch Linux / Manjaro / Fedora / Ubuntu :
- `cmake` (>= 3.20)
- `g++` ou `clang++` (support C++20)
- `qt6-base`, `qt6-declarative`, `qt6-svg`
- `dualsensectl` (version 0.7.0 recommandée)

Sur Arch Linux :
```bash
sudo pacman -S cmake qt6-base qt6-declarative qt6-svg gcc
```

### 2. Configuration des permissions Udev (Une seule fois)
Pour permettre à l'application de dialoguer avec les périphériques `/dev/hidraw*` sans privilèges `root` :
```bash
sudo ./scripts/setup_udev_rules.sh
```

### 3. Compilation & Lancement
Compilez et lancez l'application en une seule commande :
```bash
./scripts/run.sh
```
Ou manuellement avec CMake :
```bash
./scripts/build.sh
./build/dualsense-expressive
```

### 4. Installation dans le menu des applications
Pour intégrer DualSense Expressive directement dans votre lanceur d'applications Linux (KDE Plasma, GNOME, etc.) :
```bash
./scripts/install_desktop.sh
```

---

## 📋 Matrice des Commandes CLI dualsensectl

| Commande CLI | Fonction Matérielle | Intégration GUI DualSense Expressive |
| :--- | :--- | :--- |
| `dualsensectl -l` | Liste les manettes connectées | Détection auto & sélecteur de périphérique |
| `dualsensectl battery` | Niveau & état de charge | Jauge animée & badge d'état sur le Dashboard |
| `dualsensectl info` | Version du firmware & build | Carte Diagnostics & Firmware KERNEL |
| `dualsensectl lightbar on / off` | Active/désactive le halo | Switch bascule sur Dashboard & Lighting |
| `dualsensectl lightbar R G B [BRIGHTNESS]` | Couleur RGB & luminosité (0-255) | Roue HSV, sélecteur Hex, curseur luminosité |
| `dualsensectl led-brightness LEVEL` | Dimming LEDs (0-2) | Chips d'atténuation (Lumineux, Moyen, Atténué) |
| `dualsensectl player-leds NUMBER` | LEDs joueur (0-5) | Sélecteur de LEDs Joueur 0 à 5 |
| `dualsensectl microphone on / off` | Muet micro matériel | Bouton expressif Mute & Floating Action Button |
| `dualsensectl microphone-led on/off/pulse`| Comportement LED orange | Chips On, Off, Pulse dans l'onglet Audio |
| `dualsensectl microphone-mode STATE` | Usage chat / asr / both | Chips de mode micro dans l'onglet Audio |
| `dualsensectl speaker STATE` | Routage casque / interne / both | Chips de routage audio dans l'onglet Audio |
| `dualsensectl volume VOLUME` | Volume maître (0-255) | Curseur de volume avec bulle numérique |
| `dualsensectl attenuation RUMBLE TRIGGER` | Atténuation haptique (0-7) | Sliders d'atténuation moteurs & gâchettes |
| `dualsensectl trigger <tgt> off` | Réinitialise les gâchettes | Bouton Réinitialiser & mode Off |
| `dualsensectl trigger <tgt> feedback` | Résistance de position | Sliders Position & Force + Graphique courbe |
| `dualsensectl trigger <tgt> weapon` | Cran de tir d'arme à feu | Sliders Start, Stop, Force + Graphique courbe |
| `dualsensectl trigger <tgt> bow` | Tension d'arc élastique | Sliders Start, Stop, Tension, Snapforce |
| `dualsensectl trigger <tgt> galloping` | Battement de galop | Sliders Start, Stop, Pied 1, Pied 2, Cadence |
| `dualsensectl trigger <tgt> machine` | Mitrailleuse saccadée | Sliders Start, Stop, Forces A/B, Fréquence, Période |
| `dualsensectl trigger <tgt> vibration` | Vibration continue arm | Sliders Position centrale, Amplitude, Fréquence |
| `dualsensectl power-off` | Extinction manette (BT) | Bouton extinction & menu plateau système |

---

## 📄 Licence

Distribué sous la licence **MIT**. Voir [LICENSE](LICENSE) pour plus de détails.
