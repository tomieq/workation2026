# Wedding Seating Solver — IntelliJ + GitHub Copilot

To jest repo startowe. **Nie ma tutaj gotowego `spec.md`, `plan.md`, `tasks.md` ani algorytmu. To celowe.**

## Środowisko

Zakładamy, że **GitHub Copilot Plugin jest już zainstalowany, zalogowany i działa w IntelliJ IDEA**.

Nie instalujecie osobnego Copilot CLI i nie konfigurujecie VS Code.

`bootstrap-spec-kit.sh` przygotowuje wyłącznie **Spec Kit v0.16.4** i repozytoryjne pliki integracji Copilot. Nie instaluje Copilota.

## Kontrakt uruchomienia

Wasz wynik ma być programem w Kotlinie uruchamianym jako:

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

## Build

Repo zawiera lokalny launcher `gradlew`. Pierwsze uruchomienie pobierze Gradle 8.13.

```bash
./gradlew clean compile
```

Copilot jest zakładany jako już skonfigurowany w IntelliJ — `gradlew` nie instaluje ani nie konfiguruje Copilota.
