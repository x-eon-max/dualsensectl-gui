"""
Application entry point for dualsensectl-gui.
"""

import argparse
import logging
import sys

from PyQt6.QtWidgets import QApplication, QMessageBox
from PyQt6.QtCore import Qt

from .core.wrapper import DualSenseCTLWrapper
from .ui.main_window import MainWindow


def main():
    parser = argparse.ArgumentParser(description="DualSense PS5 Controller Manager GUI (dualsensectl)")
    parser.add_argument("--demo", "--simulate", action="store_true", help="Start in simulated demo mode")
    parser.add_argument("--debug", action="store_true", help="Enable verbose debug logging")
    parser.add_argument("--dualsensectl-path", type=str, default=None, help="Custom path to dualsensectl executable")
    args = parser.parse_args()

    # Logging setup
    log_level = logging.DEBUG if args.debug else logging.INFO
    logging.basicConfig(
        level=log_level,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
    )

    app = QApplication(sys.argv)
    app.setApplicationName("DualSense Manager")
    app.setOrganizationName("DualSenseLinux")

    # Initialize Wrapper
    wrapper = DualSenseCTLWrapper(
        executable_path=args.dualsensectl_path,
        simulation_mode=args.demo
    )

    if not wrapper.is_installed and not args.demo:
        # Prompt user that dualsensectl was not found in PATH
        reply = QMessageBox.warning(
            None,
            "dualsensectl Not Found",
            "The 'dualsensectl' binary could not be found in your system PATH.\n\n"
            "Would you like to start in Demo / Simulation Mode instead?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
            QMessageBox.StandardButton.Yes
        )
        if reply == QMessageBox.StandardButton.Yes:
            wrapper.simulation_mode = True
        else:
            sys.exit(1)

    window = MainWindow(wrapper)
    window.show()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
