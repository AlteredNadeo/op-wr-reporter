void Main() {
    Intercept::Init();
}
void OnDestroyed() { Intercept::Reset(); }

void OnDisabled()  { Intercept::Reset(); }
void OnEnabled()  { Intercept::Init(); }
