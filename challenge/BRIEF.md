# Operacja: Posadź ich i przeżyj wesele

Bartek i Nina biorą ślub.

Sala jest.  
Jedzenie jest.  
Muzyka jest.  
Alkohol — według kilku niezależnych źródeł — również został zabezpieczony.

Pozostał ostatni drobiazg:

> **Przyporządkujcie 30 uczestników do 5 stołów po 6 osób tak, żeby Bartek i Nina byli możliwie najbardziej zadowoleni.**

Brzmi jak piętnaście minut w Excelu.

Bartek też tak myślał.

Potem otworzył listę gości.

Okazało się, że znajdują się na niej rodzina, znajomi, koledzy z pracy, ludzie, którzy uwielbiają parkiet, ludzie, których podobno ktoś kiedyś na nim widział, oraz kilka przypadków, dla których diagram zależności powinien powstać w osobnym repozytorium.

Na szczęście Bartek jest programistą.

A kiedy programista spotyka problem społeczny, którego nie da się rozwiązać restartem, robi jedyną rozsądną rzecz:

**automatyzuje go.**

Tym razem jednak kod napiszecie Wy.

---

# Wasza misja

Zbudujcie w Swift program, który na podstawie dostarczonego JSON-a z informacjami o gościach wygeneruje JSON z planem ich usadzenia.

Cel jest prosty:

> **Bartek i Nina mają być możliwie najbardziej zadowoleni z końcowego układu.**

Nie szukamy ręcznie przygotowanego `seating-plan.json`.

Nie szukamy również:

```swift
guests.sorted { $0.name < $1.name }.chunked(into: 6)
```

i komentarza:

> „U mnie wygląda dobrze.”

Rozwiązanie ma być **programem**, który analizuje dostarczone dane i sam generuje plan.

Dobrze byłoby również, gdyby nie rozpadał się przy pierwszej zmianie wymagań.

Nie żebyśmy coś sugerowali.

---

# Pracujecie ze Spec Kit

To nie jest klasyczne:

> „Odpal Copilota i zobaczymy, ile kodu napisze przed lunchem.”

Projekt wykonujecie zgodnie z podejściem **Spec-Driven Development przy użyciu Spec Kit**.

Wasza droga wygląda tak:

```text
constitution
→ specify
→ clarify
→ plan
→ checklist
→ tasks
→ analyze
→ implement
→ converge
```

Nie dostajecie gotowego:

- `spec.md`,
- `plan.md`,
- `tasks.md`,
- modelu domenowego,
- algorytmu,
- ani rozwiązania.

Dostajecie **problem**.

Najpierw go zrozumcie. Potem stwórzcie specyfikację. Znajdźcie niejasności. Zaplanujcie rozwiązanie. Rozbijcie pracę na zadania. Dopiero później zabierajcie się za implementację.

Zanim Copilot wygeneruje `AbstractWeddingGuestPlacementStrategyFactory`, warto się zastanowić, czy na pewno tego potrzebujecie.

AI jest Waszym narzędziem.

Nie kierownikiem wesela.

Jeżeli model z pełnym przekonaniem uzna, że najłatwiejszym sposobem na zadowolenie Pary Młodej jest usunięcie pozostałych 28 osób z wejścia, to nadal **Wy odpowiadacie za produkcję**.

---

# Sala

Macie dokładnie **5 stołów po 6 miejsc**.

| Stół | Miejsca | Lokalizacja |
|---|---:|---|
| **T1 — Production** | 6 | stół Pary Młodej |
| **T2 — Development** | 6 | przy parkiecie |
| **T3 — Test Environment** | 6 | środek weselnego ruchu |
| **T4 — Hotfix** | 6 | przy wyjściu / tarasie |
| **T5 — Legacy** | 6 | spokojniejsza część sali |

Łącznie:

**30 miejsc.**

Nie ma zapasu.

Nie ma autoskalowania.

Nie można dostawić szóstego stołu.

Architektura została zatwierdzona.

## Production

Przy stole `T1 — Production` obowiązkowo siedzą:

- **Bartek**
- **Nina**

Pozostają cztery wolne miejsca.

Kogo tam posadzicie?

Rodzinę? Znajomych? Ludzi, którzy rozkręcą imprezę? Osoby, które przede wszystkim nie doprowadzą do sytuacji, w której Nina po pierwszym daniu zapyta:

> „Kto ich tu posadził?”

To już Wasz problem.

Znaczy się:

**Wasza decyzja architektoniczna.**

---

# Jak podejść do listy gości?

Nie traktujcie poniższych opisów wyłącznie jako fabularnego dodatku.

Wśród pozornie nieistotnych historii, żartów i szczegółów mogą znajdować się informacje, które pomogą ustalić, gdzie dana osoba najlepiej odnajdzie się podczas wesela.

Czasem znaczenie może mieć wspólna historia dwóch osób. Czasem sposób, w jaki ktoś spędza imprezę. Czasem temat, o którym konkretni ludzie mogliby rozmawiać zdecydowanie dłużej, niż ktokolwiek przy stole by sobie tego życzył.

Krótko mówiąc:

> **czytajcie opisy uważnie.**

Nie każda informacja musi mieć znaczenie.

Ale jeśli coś brzmi podejrzanie konkretnie, istnieje szansa, że Bartek nie opowiadał tego wyłącznie po to, żeby zwiększyć liczbę znaków w README.

Waszym zadaniem nie jest tylko zmieścić 30 osób przy pięciu stołach.

Macie spróbować zrozumieć tych ludzi na tyle dobrze, żeby stworzyć układ, po którym Bartek i Nina nie będą musieli po pierwszym daniu robić ręcznego hotfixa.

---

# Lista gości

## 1. Mama Ela

Mama Ela nie zamierzała ryzykować, że na ślubie syna pojawi się w czymś, co ma na sobie jeszcze pół sali.

Dlatego zrobiła jedyną rozsądną rzecz:

**sama uszyła sobie kreację.**

Projekt, wykonanie, testy jakości i wdrożenie przeprowadzone in-house.

Jeżeli ktoś przy stole zapyta:

> „O, a gdzie kupiłaś sukienkę?”

należy przewidzieć odpowiednio dużo czasu na odpowiedź.

---

## 2. Oliwia

Oliwia przygotowywała się do wesela metodą iteracyjną.

Zamówiła sukienkę. Odesłała. Zamówiła następną. Odesłała.

Proces powtórzył się siedem razy.

Aktualnie bardziej niż na wesele czeka chyba na:

**zwrot pieniędzy za 7 odesłanych sukienek.**

Posiada zaawansowaną wiedzę z zakresu kurierów, etykiet zwrotnych i wiadomości zaczynających się od:

> „Dzień dobry, chciałam zapytać o status mojego zwrotu...”

---

## 3. Babcia Ela

Babcia Ela dowiedziała się, że będzie wesele.

Opcja niepojawienia się nigdy nie przeszła nawet do analizy technicznej.

Nie po to człowiek przeżył kilka dekad rodzinnych imprez, żeby ominąć taką produkcję.

Prawdopodobnie przed końcem wieczoru zdąży ocenić jedzenie, zauważyć kto schudł, kto przytył i wyjaśnić, że kiedyś wesela robiło się trochę inaczej.

---

## 4. Piotr

Relacja Piotra z parkietem owiana jest legendą.

Podobno ktoś kiedyś widział go tańczącego.

Źródło jest anonimowe.

Nagrania nie istnieją.

Piotr nie potwierdza ani nie zaprzecza.

Do dziś nie wiadomo, czy wydarzenie rzeczywiście miało miejsce, czy jest po prostu jednym z najdłużej utrzymujących się mitów rodzinnych.

---

## 5. Agnieszka

Agnieszka jest ogromną zwolenniczką szybkiego feedbacku.

Jeżeli obsługa zrobi coś dobrze — nie ma problemu.

Jeżeli zrobi źle — informacja zwrotna może zostać przekazana bardzo szybko, bez ankiety satysfakcji i zbędnego procesu eskalacyjnego.

Istnieje również możliwość wykorzystania gestu powszechnie rozpoznawalnego bez względu na barierę językową.

---

## 6. Zdzisiek

Zdzisiek posiada rekord Polski, którego Guinness nadal boi się oficjalnie zweryfikować:

**8,7 poruszonego tematu na minutę.**

Może rozpocząć rozmowę od pogody, a 90 sekund później omawiać samochody, ceny paliwa, remont drogi, grzyby, emerytury, politykę monetarną, fotowoltaikę oraz człowieka, którego spotkał pod Radomiem w 1997 roku.

Najbardziej imponujące jest to, że dla Zdzisia wszystko stanowi **jeden spójny wątek**.

---

## 7. Chrzestna Ania

Rodzinny wodzirej.

Nie potrzebuje mikrofonu.

**Mikrofon potrzebuje jej.**

Jeżeli impreza zacznie zwalniać, Ania jest w stanie w ciągu kilku minut postawić ludzi na nogi, uruchomić pociąg i wciągnąć do zabawy osoby, które chwilę wcześniej „tylko na chwilę wyszły z pokoju”.

---

## 8. Zosia

Zosia specjalizuje się w integracji prowadzonej poza główną salą.

Najczęściej rozpoczyna proces od pytania:

> „Idziemy na papieroska?”

Podczas piętnastominutowej sesji terenowej jest w stanie dowiedzieć się więcej o aktualnej sytuacji weselnej niż pozostali uczestnicy przez trzy godziny.

---

## 9. Gosia

Gosia na to wesele czeka prawdopodobnie bardziej niż Para Młoda.

Możliwe, że posiada dokładniejszy harmonogram, większą gotowość operacyjną i playlistę awaryjną.

Jeżeli DJ o 4 rano zacznie składać sprzęt, Gosia może potraktować to jako **nieautoryzowane wyłączenie systemu produkcyjnego**.

---

## 10. Amelka

Amelka świetnie podejmuje decyzje, dopóki istnieje jedna opcja.

Przy dwóch zaczyna analizować.

Przy trzech porównuje.

Przy pięciu następuje:

```text
DecisionMakingException: TooManyOptions
```

Jeżeli kelner przedstawi wystarczająco długą kartę, istnieje realne ryzyko, że pozostali skończą jeść, zanim Amelka wybierze.

---

## 11. Ada

Ada posiada srebrny medal olimpijski w rzucie talerzem.

Olimpiada nie była oficjalna.

Konkurencja również.

Pojawiła się spontanicznie.

Najważniejsza zasada:

> Nie mówić Adzie: „Założę się, że nie trafisz.”

---

## 12. Kacper

Kacper w pewnym momencie wieczoru zagra koncert na **Sparkling Piano**.

Kiedy? Nie wiadomo.

Jak długo? Również nie wiadomo.

Czy ktoś go o to poprosi?

To już jest pytanie dla ludzi, którzy nie rozumieją prawdziwej sztuki.

---

## 13. Klara

Klara ma bardzo sprecyzowany cel weselny.

Nie jest nim tort.

Nie są nim oczepiny.

Klara czeka, aż ktoś poda jej:

**drinka alkoholowego.**

Oczywiście mogłaby sama podejść do baru.

Ale wtedy gdzie byłaby magia wesela?

---

## 14. Jacek

Jacek posiada jedno bardzo jasno określone KPI:

**nie zasnąć przed 21:00.**

22:30 traktujemy jako stretch goal.

Północ oznacza sukces projektu wykraczający poza pierwotne założenia biznesowe.

---

## 15. Świadek Kuba

Kuba pełni funkcję świadka.

Formalnie ma wspierać Pana Młodego.

Nieformalnie jest zagrożeniem dla powierzchni użytkowej parkietu.

Jego styl tańca został określony jako:

**nieskromny.**

Jest to prawdopodobnie najbardziej dyplomatyczne możliwe określenie.

---

# Delegacja korporacyjna

W tym miejscu kończy się klasyczne wesele.

Zaczyna się:

**firmowa integracja z rosołem.**

---

## 16. Przemek

Przemek jest człowiekiem spokojnym, profesjonalnym i niezwykle konsekwentnym.

Konsekwentnie się **nie uśmiecha**.

Przez lata prowadzono testy.

Żarty — brak reakcji.  
Piątek — brak reakcji.  
Udany release — minimalne drgnięcie kącika ust.

Odkryto jednak jeden edge case.

Jeżeli Pan Młody przebierze się za odpowiednią gwiazdę estrady, Przemek może się uśmiechnąć.

Zjawisko rzadkie, ale udokumentowane.

Przemek ma jeszcze jedną bardzo ważną kompetencję:

**dojścia do taniego spirytusu.**

Jeżeli po północy pojawi się propozycja wspólnego toastu, raczej nie będzie trzeba długo tłumaczyć mu wymagań.

W pracy Przemek reprezentuje **dział QA**.

To oznacza, że gdy developer mówi:

> „U mnie działa.”

Przemek potrafi spojrzeć na niego w sposób, który automatycznie tworzy nowego buga w Jirze.

Jeżeli coś nie działa, chce kroki reprodukcji. Jeżeli działa tylko czasami — tym lepiej, będzie ciekawiej. Jeżeli ktoś napisze `cannot reproduce`, istnieje ryzyko, że Przemek potraktuje to osobiście.

Na weselu natomiast obejmuje dodatkową funkcję:

**Strategic Procurement & Quality Assurance Manager.**

Przemek jest również właścicielem Toyoty.

---

## 17. Paweł

Paweł jest liderem technicznym.

Perfekcyjnym liderem technicznym.

Podobno nigdy się nie myli.

Kiedy rzeczywistość nie zgadza się z jego przewidywaniami, Paweł nie poprawia przewidywań.

Najpierw sprawdza, czy przypadkiem:

**rzeczywistość nie jest źle skonfigurowana.**

Code review Pawła zazwyczaj kończy się jednym z dwóch komunikatów:

```text
Approved
```

albo:

```text
Conversation required
```

Ten drugi budzi zdecydowanie większy niepokój.

Ostatnio Paweł na imprezach preferuje tryb z pełnym monitoringiem do końca wieczoru i raczej nie ściga się w liczbie toastów.

---

## 18. Leszek

Leszek niedawno dołączył do elitarnego **Klubu Toyoty**.

Od tego momentu istnieje ryzyko, że na część problemów odpowiada:

> „Toyota by tak nie zrobiła.”

Jest też właścicielem wyjątkowo interesujących relacji z ludźmi z SRE.

Komunikacja jest oczywiście profesjonalna.

Każda wiadomość zaczyna się od:

> „Hej”

a później przez piętnaście minut analizuje się, czy słowo „hej” nie miało przypadkiem pasywno-agresywnego charakteru.

Leszek posiada też spore ambicje toastowe. Problem w tym, że organizm ostatnio prowadzi w tej sprawie własny capacity planning.

**Chciałby więcej, niż aktualnie powinien.**

---

## 19. Mariusz

Mariusz posiada niezwykły dar znajdowania usprawiedliwienia dla każdego.

Ktoś zawalił?

> „Miał dużo roboty.”

Ktoś spóźnił się tydzień?

> „Ale finalnie dowiózł.”

Produkcja się pali?

> „Najważniejsze, że monitoring zadziałał.”

Mariusz bardzo lubi Sławka M. i jest jego jednoosobowym działem PR.

Jednocześnie pilnuje kosztów w zespole.

Jeżeli podczas wesela ktoś zamówi dodatkową drogą butelkę, istnieje ryzyko, że Mariusz przygotuje forecast wydatków do końca imprezy.

Bardzo lubi również docinać Przemkowi.

Po godzinach potrafi też bardzo konsekwentnie pilnować, żeby **żaden zaplanowany toast nie zginął w backlogu**.

---

## 20. Tomek

Tomek jest łysy.

Informacja okaże się bardziej istotna, niż początkowo mogłoby się wydawać.

Aktualnie znajduje się na wypożyczeniu w innym zespole.

Formalnie swój.

Praktycznie:

**najemnik.**

Na imprezach lubi zamawiać **szampana i winogrona**, co sugeruje styl życia francuskiej arystokracji.

Sam jednak obecnie częściej celebruje **styl niż liczbę opróżnionych kieliszków**.

---

## 21. Sławek M.

Sławek M. jest ekonomistą i politykiem kojarzonym przede wszystkim z tematami gospodarki, podatków i bardzo bezpośrednią formą politycznej dyskusji.

Jeżeli przy stole ktoś przypadkiem powie:

> „W sumie to podatki nie są takie złe...”

można uznać, że właśnie nieświadomie otworzył pełny panel ekspercki.

Jeżeli przy stole zapadnie cisza, Sławek potraktuje ją jako:

**niezagospodarowany slot komunikacyjny.**

W ciągu chwili rozmowa może przejść od ceny wesela do budżetu państwa, systemu podatkowego, gospodarki i pytania, kto właściwie powinien za to wszystko zapłacić.

Mariusz go uwielbia.

Pozostali uczestnicy mogą mieć bardziej zniuansowane stanowisko.

---

## 22. Maciek

Maciek trenuje CrossFit.

Wiemy o tym.

Jak każdy.

Maciek również zadbał, żebyśmy wiedzieli.

Na co dzień zamawia ilości jedzenia odpowiadające potrzebom niewielkiej rodziny.

Dla niego typowa porcja weselna oznacza raczej:

> „Przystawka.”

Maciek jest również łysy.

Wraz z Tomkiem i Michałem stanowi więc bardzo silną reprezentację wizualną.

Jeżeli usiądą blisko siebie, należy sprawdzić ustawienie reflektorów.

Maciek zdecydowanie woli uzupełniać kalorie **w formie stałej** niż próbować bić rekordy przy barze.

---

## 23. Michał

Michał jest liderem zespołu.

Tak przynajmniej twierdzi struktura organizacyjna.

Jego releasy potrafią trwać tydzień.

Normalny release ma początek, deployment i koniec.

Release Michała posiada dodatkowo fabułę, zwroty akcji, bohaterów drugoplanowych, retrospekcję i sequel.

Michał jest łysy i posiada niezwykłe pomysły biznesowe.

Jednym z nich była:

**aplikacja do obsługi cmentarzy.**

Rynek dość stabilny.

Churn klientów raczej niewielki.

---

## 24. Jakub

Jakub jest nowy w zespole.

Fresh blood.

Nowy człowiek w młodym, dynamicznym środowisku, który jeszcze wierzy, że wszystkie procesy mają jakiś głębszy sens.

Podobno może praktycznie nie jeść.

Ta informacja automatycznie powoduje, że Maciek patrzy na niego jak na kompletnie niezrozumiały eksperyment biologiczny.

Na integracjach Jakub udowodnił jednak, że kalorie można przyjmować również **w zdecydowanie bardziej płynnej formie**.

Mieszka w Radomiu.

Czyli tam, gdzie zgodnie z polskim internetem operuje:

**Chytra Baba z Radomia.**

---

## 25. Tetiana

Tetiana jest spokojna.

Naprawdę spokojna.

Nie generuje chaosu.

Nie krzyczy.

Po prostu robi swoje.

Do momentu, w którym pojawia się muzyka.

Wtedy system wykonuje:

```text
Tetiana.setMode(DANCE_FLOOR_QUEEN)
```

Na co dzień biega, więc kondycyjnie jest przygotowana na wesele zdecydowanie lepiej niż większość sali.

O 2:30 część ludzi będzie już siedziała.

Tetiana może właśnie kończyć rozgrzewkę.

---

## 26. Donald T.

Donald T. jest premierem i politykiem z wieloletnim doświadczeniem w negocjacjach, budowaniu większości i utrzymywaniu koalicji złożonych z ludzi, którzy nie zawsze chcą tego samego.

Na weselu może więc potraktować nawet wybór:

> „Rosół czy krem?”

jak początek poważnych negocjacji.

Jeżeli przy stole powstaną dwa obozy, Donald prawdopodobnie zacznie liczyć głosy, szukać większości i sprawdzać, kto jest gotowy poprzeć kompromis przed drugim daniem.

Istnieje ryzyko, że zanim pojawi się deser, przy stole powstanie umowa koalicyjna.

---

## 27. Jarosław K.

Jarosław K. jest wieloletnim liderem i prezesem PiS, przyzwyczajonym do politycznych sporów, strategii i rozmów, w których każdy szczegół może mieć znaczenie.

Rozmowa może rozpocząć się niewinnie od:

> „Ale ładna sala.”

a zakończyć analizą sytuacji państwa, układu sił i tego, kto z kim powinien współpracować.

Jeżeli przy stole rozpocznie się debata, Jarosław zdecydowanie nie planuje być tylko obserwatorem.

A jeśli siedzą tam również Donald i Sławek, organizator powinien upewnić się, że mikrofony naprawdę zostały przy DJ-u.

---

## 28. Kuba S. „Gangus”

Kuba ma więcej tatuaży niż lat.

Tak przynajmniej głosi legenda.

Jest byłym kolegą z zespołu.

Aktualnie dostał przepustkę i postanowił:

> „A wpadnę zobaczyć, co tam u Bartka.”

Czy nazwisko było na oryginalnej liście?

Szczegół implementacyjny.

Kuba jest klasycznym wildcardem.

Może spokojnie przesiedzieć pół wieczoru.

Może również wygenerować historię, o której firma będzie rozmawiała przez kolejne trzy workation.

---

# Najważniejsze osoby w systemie

## 29. Bartek — Pan Młody

Bartek programować potrafi.

Jeżeli trzeba przejrzeć logi, znaleźć błąd, zaprojektować rozwiązanie, zakwestionować wymagania albo powiedzieć, że „to zależy”, jest w swoim naturalnym środowisku.

Natomiast kiedy zobaczył zadanie:

> „Rozsadzenie gości”

przez kilka tygodni stosował bardzo dojrzałą metodykę:

**udawał, że wymaganie nie istnieje.**

W końcu znalazł rozwiązanie.

Zrobi z tego zadanie na workation i napiszecie mu system.

To nie jest lenistwo.

To jest:

**delegowanie i rozwój zespołu poprzez praktykę.**

Bartek jest również właścicielem Toyoty.

---

## 30. Nina — Panna Młoda

Nina jest finalnym Product Ownerem całego przedsięwzięcia.

Możecie mieć:

- piękną architekturę,
- świetny algorytm,
- 100% test coverage,
- wzorowe `spec.md`,
- zielony pipeline,
- matematycznie optymalny wynik.

Jeżeli Nina spojrzy na plan i powie:

> „Nie.”

to rozwiązanie otrzymuje status:

```text
REJECTED
```

Bez appeal process.

Bez rozmowy o kompromisach architektonicznych.

Bez:

> „Ale według funkcji celu...”


---

# Drużyny rozwiązujące zadanie

Na potrzeby gry uczestnicy zostają podzieleni na trzy zespoły.

**Ten podział dotyczy wyłącznie workation i nie oznacza, że te osoby powinny siedzieć razem na weselu.**

## Zespół 1 — Perfect Build Dance Squad

- **Paweł**
- **Tetiana**
- **Kuba**

Paweł będzie pilnował, żeby rozwiązanie było perfekcyjne.

Tetiana prawdopodobnie po prostu naprawi to, nad czym pozostali będą dyskutować.

Kuba dostarcza usługę Chaos Engineering bez konieczności uruchamiania dodatkowego środowiska.

**Misja:** stworzyć rozwiązanie tak dobre, żeby nawet Paweł nie znalazł w nim błędu.

Czyli poprzeczka została zawieszona rozsądnie.

---

## Zespół 2 — No Smile Delivery

- **Bartek**
- **Mariusz**
- **Przemek**

Bartek zna problem zdecydowanie lepiej, niż powinien.

Mariusz będzie kontrolował koszty i wytłumaczy każdy problem.

Przemek zadba, żeby nikt nie zaczął świętować przed `/speckit.converge`.

**Misja:** dowieźć rozwiązanie bez przekroczenia budżetu oraz niekontrolowanych przejawów entuzjazmu.

---

## Zespół 3 — Bald Driven Development

- **Tomek**
- **Maciek**
- **Leszek**

Tomek reprezentuje outsourcing, szampana i winogrona.

Maciek będzie odpowiadał za performance oraz zapotrzebowanie kaloryczne.

Leszek wnosi Toyotę i wieloletnie doświadczenie w budowaniu wyjątkowych relacji międzyzespołowych.

**Misja:** stworzyć rozwiązanie niezawodne jak Toyota, szybkie jak Maciek idący po dokładkę i stabilne jak relacje Leszka z SRE.

---

# Co oddajecie?

Wasz program musi wygenerować plik JSON z finalnym rozmieszczeniem wszystkich 30 osób przy pięciu stołach.

Każda osoba:

- musi mieć swoje miejsce,
- może wystąpić tylko raz,
- a każdy stół musi mieć dokładnie sześciu uczestników.

Bartek i Nina siedzą przy `T1 — Production`.

Reszta jest Waszym problemem.

System zostanie poddany automatycznej weryfikacji.

Nie zakładajcie, że samo stworzenie poprawnego technicznie JSON-a oznacza dobre rozwiązanie.

To trochę jak z kodem.

To, że się kompiluje, nie znaczy jeszcze, że ktokolwiek chciał właśnie tego.

---

# Cel końcowy

Macie:

**30 osób.**

**5 stołów.**

**30 miejsc.**

**Swift.**

**GitHub Copilot.**

**Spec Kit.**

I zestaw relacji międzyludzkich, którego prawdopodobnie nie powinno się modelować bez dostępu do mocnego modelu językowego.

Przejdźcie cały proces Spec Kit.

Zbudujcie rozwiązanie.

Przetestujcie je.

Sprawdźcie, czy to, co zaimplementowaliście, rzeczywiście odpowiada temu, co wcześniej wyspecyfikowaliście.

I przede wszystkim:

**przeczytajcie opisy ludzi, zanim posadzicie ich na sześć godzin przy jednym stole.**

AI może Wam pomóc.

AI może napisać kod.

AI może znaleźć algorytm.

AI może nawet bardzo przekonująco wyjaśnić, dlaczego stworzyło idealny układ.

Ale jeżeli finalnie przy jednym stole rozpocznie się panel polityczny, przy drugim ktoś zaśnie przed pierwszym tańcem, a trzeci zamieni się w zebranie zespołu...

to nie jest:

**emergent behaviour.**

To jest:

**Wasz bug.**

Powodzenia.

Termin produkcyjny jest nieprzesuwalny.

**Rollback po rozpoczęciu wesela nie został przewidziany.**

