[...conf]

ips =
{
    variables = default_variables,
    enable_builtin_rules = true,
    rules = [[
        include /usr/local/snort/etc/snort/rules/local.rules
    ]]
}


event_filter =
{
    { sid = 1000001, type = "threshold", track = "by_src", count = 15, seconds = 60 },
    { sid = 1000002, type = "threshold", track = "by_src", count = 20, seconds = 60 },
}

[cont...]
