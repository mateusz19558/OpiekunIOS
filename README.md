# 🛡️ Opiekun PC – Natywna Aplikacja na System iOS (iPhone / iPad)

Kompletna, zaawansowana aplikacja mobilna stworzona w języku **Swift** i frameworku **SwiftUI (iOS 16+)** do zdalnego zarządzania i monitorowania komputera dziecka wyposażonego w system **OpiekunApp** oraz **OpiekunWatchdog**.

---

## 📱 Najważniejsze Funkcje Aplikacji iOS

### 1. 🔒 Błyskawiczna Blokada i Odblokowanie (Pulpit Główny)
* **Główny przełącznik Master Lock:** Jedno dotknięcie nakłada natychmiastową pełnoekranową blokadę z zegarem i zablokowaniem Alt+F4 / Menadżera Zadań.
* **Jednorazowa blokada czasowa:** Szybkie przyciski zaplanowania blokady (*za 5 min*, *za 10 min*, *za 15 min*, *za 30 min* lub własny suwak do 180 min) z licznikiem odliczania na żywo i możliwością natychmiastowego anulowania.
* **Wizualny pierścień aktywności (Activity Ring):** Pokazuje w procentach wykorzystany limit dnia, czas pozostały (w kolorze cyan) oraz limit dozwolony.
* **Szybkie dodawanie bonusów czasowych:** Przyciski `+15 min`, `+30 min`, `+1 godz.` oraz opcja `Reset ↺` zerująca licznik dzisiejszego zużycia.

### 2. 🔔 Obsługa Próśb Dziecka o Czas (Real-Time SSE & Push)
* Gdy dziecko na komputerze kliknie `[+ Czas]` i poda powód, na telefonie natychmiast pojawia się baner z dźwiękiem gongu oraz powiadomienie systemowe iOS.
* Rodzic może jednym kliknięciem wybrać: `[+15 min]`, `[+30 min]` lub `[Odrzuć]`.

### 3. 📸 Podgląd Pulpitu na Żywo w Jakości HD (Ekran)
* Pobieranie aktualnego zrzutu ekranu komputera dziecka w wysokiej rozdzielczości.
* **Płynny zoom i obrót (Pinch-to-zoom):** Przybliżanie dwoma palcami i podwójnym dotknięciem.
* **Tryb automatycznego odświeżania:** Wybór interwału (*co 5s*, *co 10s*, *co 30s* lub ręcznie).
* Możliwość bezpośredniego **zapisu zrzutu do systemowej Galerii Zdjęć** (`Photos`) lub wysłania przez menu `ShareSheet`.

### 4. 🎮 Menedżer Zadań i Blokada Gier (Reguły)
* **Inspektor uruchomionych programów na żywo:** Pobiera z PC aktualną listę aktywnych okien i gier. Rodzic widzi, czy dziecko gra w *Robloxa*, *Minecrafta* czy przegląda sieć, i może zablokować dany proces jednym dotknięciem.
* **Szybka lista blokowania:** Gotowe szablony procesów (*Roblox*, *Minecraft javaw*, *Steam*, *Discord*, *Epic Games*, *Fortnite*, *Chrome*, *Opera*, *TikTok*).
* Dodawanie dowolnych własnych nazw plików wykonywalnych `.exe`.
* **Wyłącznik sieci (Firewall Killswitch):** Odcina dziecku cały internet bez przerywania komunikacji z aplikacją rodzica.
* **Blokada stron WWW (Hosts):** Blokowanie witryn (*YouTube*, *TikTok*, *Roblox*, *Facebook*, *Instagram* itp.) z automatycznym czyszczeniem DNS.
* **Blokada systemowa Windows:** Zabezpieczenie przed wejściem w Ustawienia Windows, Panel Sterowania, Rejestr systemowy, PowerShell oraz CMD.

### 5. 💬 Komunikaty i Wiadomości na Pulpit
* Szybkie szablony rodzicielskie z ikonami emoji (*"Odrób lekcje! 📚"*, *"Kończ grę, obiad na stole! 🍲"*, *"Czas spać, wyłączam za 5 min 🌙"*).
* Pole do pisania własnych wiadomości z licznikiem znaków.
* Na ekranie PC wiadomość pojawia się jako duże okno modalne z głośnym sygnałem dźwiękowym.

### 6. 📅 Tygodniowy Harmonogram i Limity
* Oddzielne reguły dla każdego dnia tygodnia (Poniedziałek – Niedziela).
* Konfiguracja dozwolonych godzin działania (np. `14:00 - 20:00`) oraz maksymalnego limitu minut (np. `120 min`).
* Przyciski szybkiego kopiowania: `[Kopiuj Pon->Pt]` oraz `[Kopiuj Sob->Ndz]`.

### 7. 🩺 Dziennik Zdarzeń i Diagnostyka
* Zdalny podgląd pliku logów `error.log` z komputera dziecka.
* Filtrowanie zdarzeń według wagi: `BŁĘDY` (czerwony), `OSTRZEŻENIA` (żółty), `INFO` (niebieski) oraz wyszukiwarka tekstowa.
* Przycisk bezpiecznego czyszczenia dziennika bezpośrednio z telefonu.

### 8. 🔑 Bezpieczeństwo i Biometria (Face ID / Touch ID)
* Logowanie do aplikacji kodem PIN rodzica (domyślnie `1234`).
* Integracja z **Face ID / Touch ID** (`LocalAuthentication`) – błyskawiczne odblokowanie aplikacji biometrią.
* Wbudowany **skaner kodów QR** (`AVFoundation`) – wystarczy skierować aparat na ekran PC, aby aplikacja sama ustawiła adres IP i port.

---

## 📂 Struktura Projektu iOS

```text
OpiekunIOS/
├── OpiekunIOS.xcodeproj/         # Projekt Xcode (gotowy do otwarcia na macOS)
│   └── project.pbxproj
├── Package.swift                  # Swift Package Manager manifest
├── OpiekunIOS/
│   ├── App/
│   │   └── OpiekunIOSApp.swift    # Główny punkt wejścia aplikacji (@main)
│   ├── Theme/
│   │   ├── Colors.swift           # Paleta kolorów (Cyber Glassmorphism Dark)
│   │   └── ViewModifiers.swift    # Karty, glowing buttons, pill badges
│   ├── Models/
│   │   ├── GuardianStatus.swift   # Pełny model stanu komputera (DTO)
│   │   ├── AppSettings.swift      # Harmonogram i konfiguracja blokad
│   │   ├── TimeRequest.swift      # Model prośby o czas od dziecka
│   │   ├── RunningApp.swift       # Model aktywnego procesu Windows
│   │   ├── LogEntry.swift         # Model wpisu diagnostycznego
│   │   └── ConnectionProfile.swift# Profil połączenia (LAN / Cloudflare)
│   ├── Services/
│   │   ├── APIService.swift       # Klient REST Async/Await (X-Parent-PIN)
│   │   ├── SSEClient.swift        # Odbiornik zdarzeń na żywo (Server-Sent Events)
│   │   ├── BiometricAuthService.swift # Obsługa Face ID / Touch ID
│   │   ├── HapticService.swift    # Wibracje haptyczne przycisków
│   │   └── NotificationService.swift  # Powiadomienia lokalne iOS
│   ├── ViewModels/
│   │   ├── GuardianViewModel.swift# Główny stan aplikacji i akcje
│   │   ├── ScreenViewModel.swift  # Pobieranie i auto-odświeżanie zrzutu ekranu
│   │   ├── ScheduleViewModel.swift# Edytor harmonogramu tygodniowego
│   │   └── LogsViewModel.swift    # Filtrowanie i czyszczenie logów
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── PinAuthView.swift       # Wirtualna klawiatura PIN + biometria
│   │   │   ├── ServerSetupView.swift   # Konfiguracja IP/Portu/Tunelu
│   │   │   └── QRCodeScannerView.swift # Skaner QR aparatem iPhone'a
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift     # Pulpit główny
│   │   │   ├── LockControlCard.swift   # Karta blokady komputera
│   │   │   ├── TimeUsageRingCard.swift # Pierścień czasu i przyciski bonusów
│   │   │   ├── QuickActionGrid.swift   # Kafelki przełączników
│   │   │   ├── TimeRequestAlertBanner.swift # Alert o prośbie o czas
│   │   │   └── ScheduledLockSheet.swift# Suwak planowania blokady
│   │   ├── Screen/
│   │   │   └── LiveScreenView.swift    # Podgląd ekranu HD z zoomem
│   │   ├── Messages/
│   │   │   └── MessagesView.swift      # Szablony i wysyłanie wiadomości
│   │   ├── Rules/
│   │   │   ├── RulesView.swift         # Zakładki reguł
│   │   │   ├── RunningAppsSheet.swift  # Lista uruchomionych aplikacji PC
│   │   │   ├── BlockedAppsView.swift   # Menedżer zablokowanych gier
│   │   │   └── BlockedWebsitesView.swift # Menedżer stron WWW
│   │   ├── Schedule/
│   │   │   └── WeeklyScheduleView.swift# 7-dniowy harmonogram
│   │   ├── Logs/
│   │   │   └── LogsView.swift          # Podgląd błędów i logów
│   │   ├── Settings/
│   │   │   └── SettingsView.swift      # Wybór konta Windows i zmiana PIN
│   │   └── MainTabView.swift           # Dolna belka nawigacji iOS (5 zakładek)
│   └── Resources/
│       ├── Info.plist                  # Uprawnienia (Kamera, Sieć lokalna, Face ID)
│       └── Assets.xcassets/            # Ikony i kolory akcentu
```

---

## 🚀 Jak Uruchomić i Zainstalować na iPhone

### Krok 1: Otwórz projekt w Xcode
1. Skopiuj folder `OpiekunIOS` na komputer Mac.
2. Kliknij dwukrotnie plik `OpiekunIOS.xcodeproj`.
3. Wybierz jako cel symulator iPhone'a (np. *iPhone 16 Pro*) lub podłącz swój fizyczny telefon kablem USB / Wi-Fi.

### Krok 2: Podpisanie aplikacji (Signing & Capabilities)
1. W Xcode przejdź do zakładki projektu `OpiekunIOS` -> `Signing & Capabilities`.
2. Zaznacz `Automatically manage signing`.
3. W polu `Team` wybierz swoje darmowe konto Apple ID (nie jest wymagane płatne konto deweloperskie).
4. Kliknij przycisk **Run (▶)**. Aplikacja zainstaluje się bezpośrednio na Twoim telefonie!

### Krok 3: Połączenie z komputerem PC
1. **W tej samej sieci Wi-Fi (w domu):**
   - Na komputerze uruchom `OpiekunApp`.
   - Na telefonie w aplikacji kliknij ikonę serwera lub zeskanuj kod QR widoczny na monitorze komputera.
   - Wpisz PIN: **`1234`**.
2. **Poza domem (dane komórkowe LTE / 5G / z pracy):**
   - Na komputerze uruchom darmowy tunel Cloudflare:
     ```bash
     cloudflared tunnel --url http://localhost:5050
     ```
   - Otrzymany adres HTTPS (np. `https://twoj-adres.trycloudflare.com`) wklej w ustawieniach połączenia w aplikacji na telefonie.
   - Masz pełną kontrolę z dowolnego miejsca na świecie!

