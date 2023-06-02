void Main() {
  auto app = cast<CTrackMania@>(GetApp());
  CMAPRaceRecord::Enable();
  MenuMapRanking::Enable(app);
}

void OnDestroyed() {
  auto app = cast<CTrackMania@>(GetApp());
  CMAPRaceRecord::Disable(app);
  MenuMapRanking::Disable(app);
}

void OnEnabled() {
  auto app = cast<CTrackMania@>(GetApp());
  CMAPRaceRecord::Enable();
  MenuMapRanking::Enable(app);
}

void OnDisabled() {
  auto app = cast<CTrackMania@>(GetApp());
  CMAPRaceRecord::Disable(app);
  MenuMapRanking::Disable(app);
}

void Update(float dt) {
  auto app = cast<CTrackMania@>(GetApp());
  CMAPRaceRecord::Update(app);
}
