namespace MenuMapRanking {
  const string MS_EVENT_NAME = "AlteredWRReporter_UpdateMapRankingsComponent";
  const string PATCH_ORIG = "Trackmania_MapRankings::ShowRanking(_State.Controls.Frame_MapRankings, _State.CurrentTab != C_Tab_Medals);";
  const string PATCH_TXT = """
	if (_State.CurrentTab == C_Tab_ZoneRankings && !IsLoading) {
		foreach (TopRanking in MapData.TopRankings) {
			if (TopRanking.ZoneName == "World" && TopRanking.Tops.count >= 1) {
				SendCustomEvent("MLHook_Event_AlteredWRReporter_UpdateMapRankingsComponent", [MapInfo.Uid, "" ^ TopRanking.Tops[0].Score]);
			}
		}
	}
	Trackmania_MapRankings::ShowRanking(_State.Controls.Frame_MapRankings, _State.CurrentTab != C_Tab_Medals);
""";

  bool isEnabled = false;

  class Hook : MLHook::HookMLEventsByType {
    Hook() {
      super(MS_EVENT_NAME);
    }

    void OnEvent(MLHook::PendingEvent@ event) override final {
      string mapUid = event.data[0];
      string rawTime = event.data[1];
      print("Got menu event, mapUid: " + mapUid + "; rawTime: " + rawTime);
      if (rawTime == "-1") {
        return;
      }
      int64 time = Text::ParseInt(rawTime);
      Notify::Call(mapUid, time);
    }
  }
  Hook@ hook = Hook();

  void Enable(CTrackMania@ app) {
    isEnabled = true;
    Patch(app);
    MLHook::RegisterMLHook(hook, MS_EVENT_NAME);
  }

  void Disable(CTrackMania@ app) {
    isEnabled = false;
    Unpatch(app);
    MLHook::UnregisterMLHookFromAll(hook);
  }

  bool Patch(CTrackMania@ app) {
    auto mm = app.MenuManager;
    auto mccma = mm is null ? null : mm.MenuCustom_CurrentManiaApp;
    if (mccma is null) {
      print("Invariant violation: no MenuCustom_CurrentManiaApp!");
      return false;
    }

    auto uiLayers = mccma.UILayers;
    for (uint i = 0; i < uiLayers.Length; i++) {
      CGameUILayer@ curLayer = uiLayers[i];
      int start = curLayer.ManialinkPageUtf8.IndexOf("<");
      int end = curLayer.ManialinkPageUtf8.IndexOf(">");
      if (start != -1 && end != -1) {
        string manialinkName = curLayer.ManialinkPageUtf8.SubStr(start, end);
        if (manialinkName.Contains("Page_CampaignDisplay")) {
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
    auto mm = app.MenuManager;
    auto mccma = mm is null ? null : mm.MenuCustom_CurrentManiaApp;
    if (mccma is null) {
      print("Invariant violation: no MenuCustom_CurrentManiaApp!");
      return;
    }

    auto uiLayers = mccma.UILayers;
    for (uint i = 0; i < uiLayers.Length; i++) {
      CGameUILayer@ curLayer = uiLayers[i];
      int start = curLayer.ManialinkPageUtf8.IndexOf("<");
      int end = curLayer.ManialinkPageUtf8.IndexOf(">");
      if (start != -1 && end != -1) {
        string manialinkName = curLayer.ManialinkPageUtf8.SubStr(start, end);
        if (manialinkName.Contains("Page_CampaignDisplay")) {
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
