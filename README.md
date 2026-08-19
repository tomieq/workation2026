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
- `input/scenario2.json` — dane wejściowe dla aktualnego scenariusza,
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
./run.sh input/scenario2.json output/scenario2-plan.json
```

The program validates five base six-seat tables, 31 active guests, and one extra chair that the solver assigns to the best table. The output has four six-guest tables and one seven-guest table. `T1` contains Bartek, Nina, and exactly two additional work-group guests. It publishes through a temporary sibling file, so an existing output is retained if decoding, validation, planning, or encoding fails.

Output is deterministic: repeated invocations with the same input create byte-identical files. The built-in evidence catalogue prefers the dance floor (`T2`) for explicitly dance-oriented guests, the exit/terrace (`T4`) for the explicit smoke-break preference, and quiet `T5` for explicit low-energy or low-toast signals. It also uses explicit food and drink descriptions as a soft table-mate affinity when the input offers no food or bar location; group membership remains the final soft preference. Provider credentials are not read from input or written to output.

SwiftAgent-related configuration does not participate in the shipped planning path. The deterministic built-in catalogue is the sole planning input, so identical Scenario 2 inputs produce byte-identical outputs regardless of assistant availability or configuration.
