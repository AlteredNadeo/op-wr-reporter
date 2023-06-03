namespace Notify {
  dictionary cache = dictionary();

  class Payload {
    string MapUid;
    uint64 Time;

    Payload(const string &in MapUid, uint64 Time) {
      this.MapUid = MapUid;
      this.Time = Time;
    }
  }

  void Call(const string &in mapUid, uint64 time) {
    uint64 cachedTime = 0;
    if (cache.Get(mapUid, cachedTime) and cachedTime == time) {
      return;
    }

    cache.Set(mapUid, time);

    Payload@ p = Payload(mapUid, time);
    startnew(CallSync, p);
  }

  void CallSync(ref@ p) {
    Payload@ payload = cast<Payload@>(p);
    Net::HttpPost("https://tmapi.the418.gg/wrbot_api/check_wr", "{\"map_uid\":\"" + payload.MapUid + "\",\"current_wr_time\":" + payload.Time + "}", "application/json");
    print("Updated WR for map " + payload.MapUid + ", new time: " + payload.Time);
  }
}
