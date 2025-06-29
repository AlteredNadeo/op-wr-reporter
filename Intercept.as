namespace Intercept {
    bool Destroy(CMwStack &in stack, CMwNod@ nod) {
        CNetScriptHttpRequest@ req;
        try {
            @req = cast<CNetScriptHttpRequest@>(stack.CurrentNod());
        } catch {
            trace('invalid http request destroy: ' + getExceptionInfo());
            return true;
        }
        if (req is null) {
            trace('null request destroy');
            return true;
        }
        if (!req.IsCompleted) {
            return true;
        }
        if (req.StatusCode != 200) {
            return true;
        }
        if (!req.Url.StartsWith('https://live-services.trackmania.nadeo.live')) {
            return true;
        }
        
        string url = req.Url.SubStr(43);
        
        string[]@ matches = Regex::Match(url, """^/api/token/leaderboard/group/(.*)/map/([\w]{24,27})/top$""");
        if (matches.Length > 0) {
            // matches should be [entire string, group, uid]

            Json::Value@ response = Json::Parse(req.Result);
            if (!response.HasKey('mapUid') || !response.HasKey('tops')) {
                warn('Matching request but unrecognised response data');
                return true;
            }
            for (uint i = 0; i < response['tops'].Length; i++) {
                if (!response['tops'][i].HasKey('zoneName')) {
                    warn('missing zoneName');
                    continue;
                } else if (response['tops'][i]['zoneName'] == 'World') {
                    if (!response['tops'][i].HasKey('top')) {
                        warn('missing top');
                        continue;
                    }
                    Json::Value@ top = response['tops'][i]['top'];
                    for (uint j = 0; j < top.Length; j++) {
                        if (!top[j].HasKey('position') || !top[j].HasKey('score')) {
                            warn('top missing position or score');
                            continue;
                        }
                        if (top[j]['position'] == 1) {
                            Notify::Call(response['mapUid'], top[j]['score']);
                            return true;
                        }
                    }
                }
            }
        }
        
        return true;
    }

    
    bool active = false;
    void Init() {
        if (active) {
            warn('intercept already active');
            return;
        }
        try {
            Dev::InterceptProc("CNetScriptHttpManager", "Destroy", Destroy);
        } catch {
            warn("Destroy: " + getExceptionInfo());
            Intercept::Reset();
        }
    }
    void Reset() {
        if (active) {
            warn('intercept not active');
            return;
        }
        try {
            Dev::ResetInterceptProc("CNetScriptHttpManager", "Destroy");
        } catch {
            active = true;
            warn("Destroy: " + getExceptionInfo());
        }
    }
}