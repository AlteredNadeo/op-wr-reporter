void Main() {
    Intercept::Init();
}
void OnDestroyed() { Intercept::Reset(); }
void OnDisabled()  { Intercept::Reset(); }
