# Wedding Seating Solver — IntelliJ + GitHub Copilot

To jest repo startowe. **Nie ma tutaj gotowego `spec.md`, `plan.md`, `tasks.md` ani algorytmu. To celowe.**

## Środowisko

Zakładamy, że **GitHub Copilot Plugin jest już zainstalowany, zalogowany i działa w IntelliJ IDEA**.

Nie instalujecie osobnego Copilot CLI i nie konfigurujecie VS Code.

`bootstrap-spec-kit.sh` przygotowuje wyłącznie **Spec Kit v0.16.4** i repozytoryjne pliki integracji Copilot. Nie instaluje Copilota.

## Kontrakt uruchomienia

Wasz wynik ma być programem w Swift uruchamianym jako:

```bash
./run.sh <input.json> <output.json>
```

Na starcie macie:

- `challenge/BRIEF.md` — problem i lista gości,
- `challenge/room-layout.png` — układ sali,
- `input/scenario1.json` — dane wejściowe,
- `contract/output-schema.json` — minimalny kontrakt wyniku,
- `bootstrap-spec-kit.sh` — inicjalizacja Spec Kit,
- pusty katalog `src/`.

## Jak zacząć?

1. Otwórzcie repo w IntelliJ.
2. Sprawdźcie, że Copilot Chat działa i widzi pliki projektu.
3. W terminalu IntelliJ uruchomcie `./bootstrap-spec-kit.sh`.
4. Wróćcie do Copilot Chat.
5. Dalej musicie już wiedzieć, jak prowadzić projekt zgodnie ze Spec Kit. :)

Challenge jest celowo przygotowany tak, żeby **pierwszy sensowny artefakt nie był kodem**. Organizator będzie patrzył nie tylko na końcowy JSON, ale też na spójność artefaktów Spec Kit.

Nie dostajecie gotowej specyfikacji. Z nieformalnego briefu sami musicie wydobyć wymagania, wyjaśnić niejasności i dopiero później wybrać rozwiązanie techniczne.

> Jeżeli pierwszą rzeczą, jaką zrobi Copilot, będzie 700 linii kodu, prawdopodobnie właśnie ominęliście najważniejszą część zadania.

> Jeżeli drugą rzeczą będzie `WeddingGuestPlacementStrategyFactoryFactory`, rozważcie rollback.

## Build and run

The executable is a Swift Package Manager target. Build and test it with:

```bash
swift build
swift test
```

Generate a seating plan with exactly two paths:

```bash
./run.sh input/scenario1.json output/seating-plan.json
```

The program validates the fixed five-table venue and 30 unique guests, places Bartek and Nina at `T1`, and writes a canonical JSON plan only after complete validation. It publishes through a temporary sibling file, so an existing output is retained if decoding, validation, planning, or encoding fails.

Output is deterministic: repeated invocations with the same input create byte-identical files. The built-in evidence catalogue prefers the dance floor (`T2`) for explicitly dance-oriented guests and the exit/terrace (`T4`) for the explicit smoke-break preference; group membership is only a final soft preference. Provider credentials are not read from input or written to output.

An optional SwiftAgent proposal pass reads `.env` through `Env`. Start with [`.env.example`](.env.example), then enter `SWIFT_AGENT_AUTH_TOKEN` directly in an untracked `.env` file. The supplied default is OpenAI at `https://api.openai.com/v1/` with `gpt-5.4-mini`; `SWIFT_AGENT_PROVIDER`, `SWIFT_AGENT_MODEL_URL`, and `SWIFT_AGENT_MODEL` can override it. A missing, unavailable, malformed, or unsupported assistant proposal is ignored and the deterministic built-in plan is still generated.
