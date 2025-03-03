# I depend on roc-lang/http


########## APP CODE ##################

Bugsnag.new(|req| Http.send!(req).with_header("X-Bugsnag-API-Key", api_key))

Bugsnag.new(|req|
    if req.url().starts_with("https://api.bugsnag.com") then
        Http.send!(req).with_header("X-Bugsnag-API-Key", api_key)
    else
        crash "INTRUDER ALARM!!!!"
)

########## PACKAGE CODE ##################

new : BugsnagApiKey, (Request => Response) -> Bugsnag

new : (Request => Response) -> Bugsnag

error! : Bugsnag => Result a [BugnsnagFailed HttpErr]

Bugsnag.error!()

bugsnag.error!()
