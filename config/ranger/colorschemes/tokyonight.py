from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import *

class TokyoNight(ColorScheme):
    progress_bar_color = 111  # blue

    def use(self, context):
        fg, bg, attr = default_colors

        if context.reset:
            return default_colors

        # Browser area (main file list)
        if context.in_browser:
            fg = 189  # fg
            # bg = 234  # bg
            if context.selected:
                attr = reverse
            if context.empty or context.error:
                fg = 204  # red
            if context.border:
                fg = 60  # comment (gray)
            if context.media:
                fg = 183  # purple
            if context.image:
                fg = 117  # cyan
            if context.document:
                fg = 113  # green
            if context.video:
                fg = 183  # purple
            if context.audio:
                fg = 215  # orange
            if context.container:
                fg = 117  # cyan
            if context.directory:
                fg = 111  # blue
            elif context.executable and not context.directory:
                fg = 113  # green
            if context.link:
                fg = 117 if context.good else 204  # cyan / red
            if context.marked:
                attr |= bold
                fg = 215  # orange
            if context.badinfo:
                fg = 204  # red

        # Title bar (top of ranger)
        elif context.in_titlebar:
            attr |= bold
            if context.hostname:
                fg = 117 if context.good else 204
            elif context.directory:
                fg = 111
            elif context.tab:
                fg = 189 if context.good else 204
            elif context.link:
                fg = 117

        # Status bar (bottom)
        elif context.in_statusbar:
            fg = 189
            bg = 234

        # File previews (if applicable)
        if context.text:
            if context.highlight:
                attr |= reverse

        return fg, bg, attr

