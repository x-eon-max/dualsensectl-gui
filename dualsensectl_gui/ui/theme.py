"""
Design system and QSS Stylesheet for dualsensectl-gui.
Futuristic Dark / PlayStation 5 & Cyberpunk inspired aesthetic.
"""

DARK_THEME_QSS = """
/* Global Window & Typography */
QMainWindow, QDialog, QWidget {
    background-color: #0d1117;
    color: #e6edf3;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Inter", "Roboto", "Ubuntu", sans-serif;
    font-size: 13px;
}

/* Card / Container Panels */
QGroupBox {
    background-color: #161b22;
    border: 1px solid #30363d;
    border-radius: 10px;
    margin-top: 18px;
    padding: 16px 12px 12px 12px;
    font-weight: 600;
    font-size: 13px;
}

QGroupBox::title {
    subcontrol-origin: margin;
    subcontrol-position: top left;
    padding: 2px 10px;
    color: #58a6ff;
    background-color: #0d1117;
    border: 1px solid #30363d;
    border-radius: 6px;
    left: 14px;
}

/* Tab Widget Styling */
QTabWidget::pane {
    border: 1px solid #30363d;
    background-color: #161b22;
    border-radius: 8px;
    top: -1px;
}

QTabBar::tab {
    background-color: #1c2128;
    color: #8b949e;
    border: 1px solid #30363d;
    border-bottom: none;
    padding: 8px 18px;
    margin-right: 4px;
    border-top-left-radius: 8px;
    border-top-right-radius: 8px;
    font-weight: 500;
}

QTabBar::tab:selected {
    background-color: #161b22;
    color: #58a6ff;
    border-color: #58a6ff #30363d #161b22 #30363d;
    font-weight: 600;
}

QTabBar::tab:hover:!selected {
    background-color: #262c36;
    color: #f0f6fc;
}

/* Push Buttons */
QPushButton {
    background-color: #21262d;
    color: #c9d1d9;
    border: 1px solid #363b42;
    border-radius: 6px;
    padding: 7px 14px;
    font-weight: 500;
}

QPushButton:hover {
    background-color: #30363d;
    border-color: #8b949e;
    color: #ffffff;
}

QPushButton:pressed {
    background-color: #1f242c;
}

QPushButton:disabled {
    background-color: #161b22;
    color: #484f58;
    border-color: #21262d;
}

/* Primary Action Buttons */
QPushButton#primaryButton {
    background-color: #1f6feb;
    border-color: #388bfd;
    color: #ffffff;
    font-weight: 600;
}

QPushButton#primaryButton:hover {
    background-color: #388bfd;
    border-color: #58a6ff;
}

QPushButton#primaryButton:pressed {
    background-color: #1158c7;
}

/* Danger / Power Buttons */
QPushButton#dangerButton {
    background-color: #da3633;
    border-color: #f85149;
    color: #ffffff;
    font-weight: 600;
}

QPushButton#dangerButton:hover {
    background-color: #f85149;
}

/* Combo Box */
QComboBox {
    background-color: #21262d;
    border: 1px solid #363b42;
    border-radius: 6px;
    padding: 6px 12px;
    color: #f0f6fc;
}

QComboBox:hover {
    border-color: #58a6ff;
}

QComboBox::drop-down {
    subcontrol-origin: padding;
    subcontrol-position: top right;
    width: 24px;
    border-left: 1px solid #30363d;
}

QComboBox QAbstractItemView {
    background-color: #161b22;
    border: 1px solid #30363d;
    selection-background-color: #1f6feb;
    selection-color: #ffffff;
    color: #f0f6fc;
    padding: 4px;
    outline: none;
}

/* Sliders */
QSlider::groove:horizontal {
    height: 6px;
    background: #21262d;
    border-radius: 3px;
}

QSlider::sub-page:horizontal {
    background: #1f6feb;
    border-radius: 3px;
}

QSlider::handle:horizontal {
    background: #58a6ff;
    border: 2px solid #ffffff;
    width: 16px;
    margin-top: -5px;
    margin-bottom: -5px;
    border-radius: 8px;
}

QSlider::handle:horizontal:hover {
    background: #79c0ff;
    border-color: #ffffff;
}

/* SpinBox */
QSpinBox {
    background-color: #21262d;
    border: 1px solid #363b42;
    border-radius: 6px;
    padding: 5px 8px;
    color: #f0f6fc;
}

QSpinBox:hover {
    border-color: #58a6ff;
}

/* Progress Bar */
QProgressBar {
    border: 1px solid #30363d;
    border-radius: 6px;
    text-align: center;
    background-color: #0d1117;
    color: #f0f6fc;
    font-weight: 600;
}

QProgressBar::chunk {
    background-color: #238636;
    border-radius: 5px;
}

/* Tooltips */
QToolTip {
    background-color: #1c2128;
    color: #e6edf3;
    border: 1px solid #444c56;
    padding: 6px 10px;
    border-radius: 6px;
}

/* Scrollbars */
QScrollBar:vertical {
    border: none;
    background: #0d1117;
    width: 8px;
    margin: 0px;
}

QScrollBar::handle:vertical {
    background: #30363d;
    min-height: 20px;
    border-radius: 4px;
}

QScrollBar::handle:vertical:hover {
    background: #58a6ff;
}

QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
    height: 0px;
}
"""

# Color Palette Constants
COLOR_PS5_BLUE = "#0070d1"
COLOR_CYBERPUNK_CYAN = "#00f0ff"
COLOR_MAGENTA = "#e040fb"
COLOR_EMERALD = "#00e676"
COLOR_AMBER = "#ffab00"
COLOR_CRIMSON = "#ff3366"
COLOR_WHITE = "#ffffff"
COLOR_MIC_ORANGE = "#ff6b00"

PRESET_COLORS = [
    ("PlayStation Blue", COLOR_PS5_BLUE),
    ("Neon Cyan", COLOR_CYBERPUNK_CYAN),
    ("Cyberpunk Pink", COLOR_MAGENTA),
    ("Emerald Green", COLOR_EMERALD),
    ("Warning Amber", COLOR_AMBER),
    ("Crimson Red", COLOR_CRIMSON),
    ("Pure White", COLOR_WHITE),
]
