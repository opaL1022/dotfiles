-- Input configuration (migrated from input.conf)

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        numlock_by_default = true,

        follow_mouse = 1,

        sensitivity = 0.4, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.device({
    name       = "at-translated-set-2-keyboard",
    kb_options = "ctrl:swapcaps",
})

-- The old `workspace_swipe` option was removed in favour of the new gesture
-- system. Uncomment to swipe between workspaces with 3 fingers:
-- hl.gesture({
--     fingers   = 3,
--     direction = "horizontal",
--     action    = "workspace",
-- })
