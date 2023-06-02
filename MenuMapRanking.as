namespace MenuMapRanking {
  const string MS_EVENT_NAME = "TMNext_CampaignStore_Action_LoadMapTopGlobalRankings";

  bool isEnabled = false;

  class Hook : MLHook::HookMLEventsByType {
    Hook() {
      super(MS_EVENT_NAME);
    }

    void OnEvent(MLHook::PendingEvent@ event) override final {
      string mapUid = event.data[1];
      string rawTime = event.data[2];
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
    MLHook::RegisterMLHook(hook, MS_EVENT_NAME, true);
  }

  void Disable(CTrackMania@ app) {
    isEnabled = false;
    MLHook::UnregisterMLHookFromAll(hook);
  }
}
