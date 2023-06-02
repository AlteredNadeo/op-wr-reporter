namespace CMAPRaceRecord {
  const string MS_EVENT_NAME = "AlteredWRReporter_RaceRecord";
  const string PATCH_ORIG = "return ZoneRecords;";
  const string PATCH_TXT = """
foreach (Zone in _ZonesRecords) {
		if (Zone.ZoneName == "World" && Zone.Records.count >= 1) {
			SendCustomEvent("MLHook_Event_AlteredWRReporter_RaceRecord", ["" ^ Zone.Records[0].Time]);
		}
	}
	return ZoneRecords;
""";

  bool isEnabled = false;
  string curMapUid = "";
  int64 curWRTime = -1;

  class Hook : MLHook::HookMLEventsByType {
    Hook() {
      super(MS_EVENT_NAME);
    }

    void OnEvent(MLHook::PendingEvent@ event) override final {
      int64 time = Text::ParseInt(event.data[0]);
      if (curWRTime != time) {
        curWRTime = time;
        Notify::Call(curMapUid, time);
      }
    }
  }
  Hook@ hook = Hook();

  void Enable() {
    isEnabled = true;
    MLHook::RegisterMLHook(hook, MS_EVENT_NAME);
  }

  void Disable(CTrackMania@ app) {
    isEnabled = false;
    MLHook::UnregisterMLHookFromAll(hook);
    Unpatch(app);
  }

  void Update(CTrackMania@ app) {
    if (!isEnabled) return;

    auto rootMap = app.RootMap;
    if (rootMap is null) {
      curMapUid = "";
    } else {
      string mapUid = rootMap.MapInfo.MapUid;
      if (curMapUid != mapUid) {
        curWRTime = -1;

        if (Patch(app)) {
          curMapUid = mapUid;
        }
      }
    }
  }

  bool Patch(CTrackMania@ app) {
    auto cmap = app.Network.ClientManiaAppPlayground;
    if (cmap is null) {
      return false;
    }

    auto uiLayers = cmap.UILayers;
    for (uint i = 0; i < uiLayers.Length; i++) {
      CGameUILayer@ curLayer = uiLayers[i];
      int start = curLayer.ManialinkPageUtf8.IndexOf("<");
      int end = curLayer.ManialinkPageUtf8.IndexOf(">");
      if (start != -1 && end != -1) {
        string manialinkName = curLayer.ManialinkPageUtf8.SubStr(start, end);
        if (manialinkName.Contains("UIModule_Race_Record")) {
          string manialinkInitial = curLayer.ManialinkPage;
          string manialinkPatched = manialinkInitial.Replace(
            PATCH_ORIG,
            PATCH_TXT
          );
          curLayer.ManialinkPage = manialinkPatched;

          return true;
        }
      }
    }

    return false;
  }

  void Unpatch(CTrackMania@ app) {
    auto cmap = app.Network.ClientManiaAppPlayground;
    if (cmap is null) {
      return;
    }

    auto uiLayers = cmap.UILayers;
    for (uint i = 0; i < uiLayers.Length; i++) {
      CGameUILayer@ curLayer = uiLayers[i];
      int start = curLayer.ManialinkPageUtf8.IndexOf("<");
      int end = curLayer.ManialinkPageUtf8.IndexOf(">");
      if (start != -1 && end != -1) {
        string manialinkName = curLayer.ManialinkPageUtf8.SubStr(start, end);
        if (manialinkName.Contains("UIModule_Race_Record")) {
          string manialinkInitial = curLayer.ManialinkPage;
          string manialinkPatched = manialinkInitial.Replace(
            PATCH_TXT,
            PATCH_ORIG
          );
          curLayer.ManialinkPage = manialinkPatched;
        }
      }
    }
  }
}
