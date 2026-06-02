# 🎨 Hyprland Theme — Everforest Matugen

Полный тутор по воспроизведению моей темы Hyprland на твоей системе.

---

## 🚀 Быстрая установка (одной командой)

Сначала установи `curl` и `git` (в чистом Arch их нет):
```bash
sudo pacman -S curl git
```

Затем запусти:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/xtmic/hyprland/main/setup.sh)
```

Без curl тоже вариант — скачай через `wget` если он есть:
```bash
wget -qO- https://raw.githubusercontent.com/xtmic/hyprland/main/setup.sh | bash
```

Или классически — руками через git:
```bash
sudo pacman -S git
git clone git@github.com:xtmic/hyprland.git ~/hyprland-setup
cd ~/hyprland-setup
./setup.sh
```

Скрипт сам:
- Определит, что у тебя Arch-based (CachyOS, EndeavourOS и т.д.)
- Установит все пакеты (pacman + AUR через yay/paru)
- Сделает бэкап текущих конфигов
- Скопирует все настройки
- Установит шрифт JetBrains Mono Nerd Font
- Настроит Matugen шаблоны
- Применит обои и сгенерирует тему
- Проверит что всё встало

Флаги:
- `--dry-run` — показать что будет сделано без реальных изменений
- `--no-aur` — пропустить AUR-пакеты
- `--restore` — откатить последний бэкап

---

## 📦 Содержание

1. [Установка зависимостей](#1-установка-зависимостей)
2. [SSH-ключ и клонирование репозитория](#2-ssh-ключ-и-клонирование-репозитория)
3. [Установка шрифтов](#3-установка-шрифтов)
4. [Установка иконок и курсоров](#4-установка-иконок-и-курсоров)
5. [Развертывание конфигов](#5-развертывание-конфигов)
6. [Настройка обоев и Matugen](#6-настройка-обоев-и-matugen)
7. [Установка и настройка компонентов](#7-установка-и-настройка-компонентов)
   - [Hyprland](#71-hyprland)
   - [Waybar](#72-waybar)
   - [Rofi](#73-rofi)
   - [Kitty](#74-kitty)
   - [SwayNC](#75-swaync)
   - [Hyprlock](#76-hyprlock)
   - [Hypridle](#77-hypridle)
8. [Скрипты и их назначение](#8-скрипты-и-их-назначение)
9. [Как это работает: Matugen + генерация цветов](#9-как-это-работает-matugen--генерация-цветов)
10. [Хоткеи](#10-хоткеи)
11. [Запуск и первый вход](#11-запуск-и-первый-вход)
12. [Устранение проблем](#12-устранение-проблем)

---

## 1. Установка зависимостей

### Arch Linux / EndeavourOS / CachyOS
```bash
# Основные пакеты
sudo pacman -S --needed hyprland waybar rofi kitty swaync \
  grimblast wl-clipboard cliphist jq python python-pip \
  playerctl brightnessctl pacman-contrib cpupower wf-recorder \
  slurp imagemagick bc fastfetch

# AUR (через yay/paru)
yay -S --needed matugen-bin swayosd-glibc-git hyprpicker \
  hyprlock hypridle awww-git rofimoji-bin bibata-cursor-theme \
  papirus-icon-theme ttf-jetbrains-mono-nerd

# tmux (для bottomterm)
sudo pacman -S tmux

# Для postimg-upload.py
pip install playwright
playwright install chromium
```

### Другие дистрибутивы
Найди аналоги пакетов в твоем пакетном менеджере.
Ключевые зависимости:
- `hyprland` — оконный менеджер
- `waybar` — панель
- `rofi` + `rofimoji` — лаунчер и эмодзи-пикер
- `kitty` — терминал
- `swaync` — уведомления
- `matugen` — генератор Material Design 3 цветов из обоев
- `awww` — установщик обоев
- `grimblast` / `slurp` — скриншоты
- `cliphist` / `wl-clipboard` — буфер обмена
- `hyprlock` — экран блокировки
- `hypridle` — управление питанием
- `hyprpicker` — пикер цвета
- `swayosd-client` — OSD для громкости/яркости
- `playerctl` — управление музыкой
- `wf-recorder` — запись экрана
- `jq` — обработка JSON
- `tmux` — мультиплексор терминала (для bottomterm)

---

## 2. SSH-ключ и клонирование репозитория

### 2.1. Генерация SSH-ключа
```bash
ssh-keygen -t ed25519 -C "my-hyprland-key" -f ~/.ssh/id_ed25519_hyprland
```

### 2.2. Просмотр публичного ключа
```bash
cat ~/.ssh/id_ed25519_hyprland.pub
# Вывод: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... my-hyprland-key
```

### 2.3. Добавление ключа в GitHub
1. Открой https://github.com/settings/keys
2. Нажми **New SSH Key**
3. Вставь скопированный публичный ключ
4. Сохрани

### 2.4. Настройка SSH config
```bash
nano ~/.ssh/config
```
Добавь:
```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_hyprland
  IdentitiesOnly yes
```

### 2.5. Клонирование репозитория
```bash
git clone git@github.com:xtmic/hyprland.git ~/hyprland-dotfiles
```

---

## 3. Установка шрифтов

Тема использует **JetBrains Mono Nerd Font Propo** (версия с пропорциональными цифрами).

```bash
# Через pacman (если доступно)
sudo pacman -S ttf-jetbrains-mono-nerd

# Или вручную
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
mkdir -p ~/.local/share/fonts
tar -xf JetBrainsMono.tar.xz -C ~/.local/share/fonts/
fc-cache -fv
```

Проверь установку:
```bash
fc-list | grep -i "JetBrainsMono.*Nerd"
```

---

## 4. Установка иконок и курсоров

### Тема иконок — Papirus
```bash
sudo pacman -S papirus-icon-theme
```

### Тема курсора — Bibata-Modern-Classic
```bash
# AUR
yay -S bibata-cursor-theme

# Или вручную скачай с https://github.com/ful1e5/Bibata_Cursor
```

Установи курсор глобально (опционально):
```bash
sudo ln -s /usr/share/icons/Bibata-Modern-Classic /usr/share/icons/default
```

### Настройка в Hyprland (уже в конфиге)
В `config/hypr/hyprland-gui.conf` прописано:
```conf
env = XCURSOR_THEME,Bibata-Modern-Classic
env = XCURSOR_SIZE,24
```

---

## 5. Развертывание конфигов

### Быстрый способ — символические ссылки
```bash
cd ~/hyprland-dotfiles

# Создаем бэкап текущих конфигов
mkdir -p ~/.config-backup
cp -r ~/.config/hypr ~/.config-backup/hypr 2>/dev/null
cp -r ~/.config/waybar ~/.config-backup/waybar 2>/dev/null
cp -r ~/.config/rofi ~/.config-backup/rofi 2>/dev/null
cp -r ~/.config/kitty ~/.config-backup/kitty 2>/dev/null
cp -r ~/.config/swaync ~/.config-backup/swaync 2>/dev/null

# Создаем ссылки
ln -sf "$PWD/config/hypr" ~/.config/hypr
ln -sf "$PWD/config/waybar" ~/.config/waybar
ln -sf "$PWD/config/rofi" ~/.config/rofi
ln -sf "$PWD/config/kitty" ~/.config/kitty
ln -sf "$PWD/config/swaync" ~/.config/swaync

# Скрипты
mkdir -p ~/Scripts
ln -sf "$PWD/scripts/General" ~/Scripts/General

# Обои
mkdir -p ~/Pictures/Wallpaper
ln -sf "$PWD/wallpaper/Everforest" ~/Pictures/Wallpaper/Everforest
ln -sf "$PWD/wallpaper/wallz" ~/Pictures/Wallpaper/wallz
```

### Способ для новичков — копирование файлов
```bash
cp -r ~/hyprland-dotfiles/config/hypr ~/.config/hypr
cp -r ~/hyprland-dotfiles/config/waybar ~/.config/waybar
cp -r ~/hyprland-dotfiles/config/rofi ~/.config/rofi
cp -r ~/hyprland-dotfiles/config/kitty ~/.config/kitty
cp -r ~/hyprland-dotfiles/config/swaync ~/.config/swaync
cp -r ~/hyprland-dotfiles/scripts/General ~/Scripts/General
cp -r ~/hyprland-dotfiles/wallpaper/* ~/Pictures/Wallpaper/
```

---

## 6. Настройка обоев и Matugen

### Обои
В репозитории два набора обоев:
- **Everforest/waterfall.png** — основные обои (30MB, высокое разрешение)
- **wallz/CatppuccinMocha/07.CatppuccinMocha.png** — запасной вариант

### Скрипт wallpaper.sh
Скрипт `~/Scripts/General/wallpaper.sh` делает всё автоматически:

```bash
# Установить конкретные обои
~/Scripts/General/wallpaper.sh ~/Pictures/Wallpaper/Everforest/waterfall.png

# Случайные обои из папки
~/Scripts/General/wallpaper.sh --random ~/Pictures/Wallpaper/Everforest

# Выбрать обои через GUI (нужен yad или zenity)
~/Scripts/General/wallpaper.sh --pick

# Сгенерировать тему из цвета (без смены обоев)
~/Scripts/General/wallpaper.sh --color "#7c7c9d"

# Повторно применить последние обои (после перезагрузки)
~/Scripts/General/wallpaper.sh
```

### Что делает `wallpaper.sh`:
1. Устанавливает обои через `awww img <file>`
2. Запускает `matugen` с параметрами:
   - `-t scheme-neutral` — нейтральная цветовая схема
   - `--contrast 0.3` — контраст
   - `--lightness-dark 0.1` — яркость темной темы
   - `--prefer value` — предпочитать значение (Value) в HSV
3. Matugen генерирует цвета Material Design 3 из обоев
4. Обновляет все конфиги (hypr/colors.conf, waybar/colors.css, rofi/colors/matugen.rasi, kitty/current-theme.conf, swaync/colors/matugen.css)
5. Перезагружает kitty через `pkill -USR1 kitty`

### Настройка параметров Matugen
Открой `~/Scripts/General/wallpaper.sh` и измени эти переменные:
```bash
MATUGEN_SCHEME="scheme-neutral"     # или "scheme-tonal", "scheme-vibrant", etc.
MATUGEN_CONTRAST="0.3"              # 0.0 - 1.0
MATUGEN_LIGHTNESS="0.1"             # 0.0 - 1.0 (яркость темной темы)
MATUGEN_PREFER="value"              # "hue", "saturation", "value"
```

### Смена обоев при запуске
Добавь в `config/hypr/modules/startup.conf`:
```conf
exec-once = ~/Scripts/General/wallpaper.sh ~/Pictures/Wallpaper/Everforest/waterfall.png
```

---

## 7. Установка и настройка компонентов

### 7.1. Hyprland

#### Структура конфига
```
~/.config/hypr/
├── hyprland.conf              # Главный конфиг (импортирует всё остальное)
├── colors.conf                # Material Design 3 цвета (генерируется Matugen)
├── hyprlock.conf              # Экран блокировки
├── hypridle.conf              # Управление питанием
├── hyprland-gui.conf          # Настройки из HyprMod (курсор, анимации, бинды)
├── hyprmod/
│   └── user_curves.json       # Пользовательские кривые анимаций
├── modules/
│   ├── startup.conf           # Автозапуск
│   ├── monitors.conf          # Мониторы
│   ├── envvars.conf           # Переменные окружения
│   ├── input.conf             # Ввод (клавиатура, тачпад)
│   ├── binds.conf             # Горячие клавиши
│   ├── animations.conf        # Анимации
│   ├── appearance.conf        # Внешний вид (gaps, border, blur, shadow)
│   ├── windowrules.conf       # Правила для окон
│   └── misc.conf              # Разное
└── scripts/                   # Пользовательские скрипты
```

#### Редактирование под твой монитор
Открой `config/hypr/modules/monitors.conf`:
```conf
monitor=,preferred,1920x1080@60,1
```
Замени `1920x1080@60` на твое разрешение и частоту.
Для ноутбука с несколькими мониторами:
```conf
monitor=eDP-1,1920x1080@60,0x0,1
monitor=HDMI-A-1,1920x1080@60,1920x0,1
```
Узнать название мониторов:
```bash
hyprctl monitors
```

#### Настройка раскладки клавиатуры
В `config/hypr/modules/input.conf`:
```conf
input {
    kb_layout = us,ru
    kb_options = caps:escape,grp:alt_shift_toggle
}
```
Поменяй `us,ru` на свои языки, `alt_shift_toggle` на удобную комбинацию.

### 7.2. Waybar

```
~/.config/waybar/
├── config.jsonc              # Конфигурация модулей
├── style.css                 # Стилизация (451 строка, полная кастомизация)
├── colors.css                # Material Design 3 цвета (генерируется Matugen)
├── V23.png                   # Иконка (не используется)
└── scripts/
    ├── resources.sh          # Мониторинг ресурсов (CPU/RAM/Disk/Temp/GPU)
    ├── disk.sh               # Использование диска
    ├── color-picker.sh       # Пикер цвета (hyprpicker)
    └── mpris-pill.sh         # Прогресс-бар музыки
```

#### Как работает waybar
- **Позиция**: сверху
- **Стиль**: капсулы (border-radius: 26px) с полупрозрачным фоном
- **Группы**: левая (лого, рабочие столы, ресурсы, музыка), центр (окно, часы), правая (трей, звук, раскладка, BT, сеть, батарея, уведомления)
- **Цвета**: все цвета из `colors.css`, который генерирует Matugen

#### Группы модулей
| Группа | Модули | Описание |
|--------|--------|----------|
| left1 | custom/arch | Иконка Arch, открывает rofi по клику |
| left2 | hyprland/workspaces | Рабочие столы |
| resources | custom/resources-icon, cpu, memory, custom/disk | Мониторинг ресурсов (выпадающий drawer) |
| left3 | custom/music-pill | Музыкальный прогресс-бар |
| center-window | hyprland/window | Название активного окна |
| center-clock | clock | Часы |
| right | pulseaudio, custom/kb-layout, bluetooth, network, battery, custom/notification | Системные индикаторы |
| tray-expander | custom/expand-icon, custom/color-picker, cpu, memory | Выпадающий трей |

### 7.3. Rofi

```
~/.config/rofi/
├── config.rasi               # Глобальная конфигурация
├── colors/
│   └── matugen.rasi          # Material Design 3 цвета (генерируется Matugen)
├── launchers/
│   ├── type-1/               # Лаунчер приложений
│   │   ├── launcher.sh       # Запуск (drun)
│   │   ├── style-5.rasi      # Тема
│   │   └── shared/
│   │       ├── colors.rasi   # Импорт matugen.rasi
│   │       └── fonts.rasi    # Шрифт
│   └── emoji/                # Эмодзи-пикер (rofimoji)
│       ├── launcher.sh       # Запуск
│       └── grid.rasi         # Тема
├── powermenu/
│   └── type-2/               # Меню выключения
│       ├── powermenu.sh      # Запуск
│       ├── style-2.rasi      # Тема
│       └── shared/
│           ├── colors.rasi   # Импорт matugen.rasi
│           └── fonts.rasi    # Шрифт
└── scripts/
    ├── launcher_t1           # Запуск лаунчера
    ├── powermenu_t2          # Запуск меню питания
    ├── clipboard             # Просмотр истории буфера обмена (cliphist)
    └── emoji                 # Запуск эмодзи-пикера
```

#### Цветовая схема Rofi
Все темы rofi импортируют `~/.config/rofi/colors/matugen.rasi`, который содержит переменные Material Design 3:
```
* {
    primary: #cccadb;
    on-primary: #333346;
    surface: #2b292d;
    on-surface: #f8f3f6;
    ...
    background: @surface-container-high;
    foreground: @on-surface-variant;
    selected: @primary;
}
```

### 7.4. Kitty

```
~/.config/kitty/
├── kitty.conf                # Конфигурация терминала
├── current-theme.conf        # Material Design 3 цвета (генерируется Matugen)
└── themes/
    └── Matugen.conf          # Запасной файл темы
```

#### Особенности конфига kitty
- **Шрифт**: JetBrains Mono Nerd Font, 12px
- **Прозрачность**: background_opacity 0.3 (30% непрозрачности)
- **Курсор**: beam (вертикальная линия)
- **Табы**: powerline style slanted
- **Цвета**: подгружаются из `current-theme.conf`

### 7.5. SwayNC (уведомления)

```
~/.config/swaync/
├── config.json               # Конфигурация
├── style.css                 # Стилизация
└── colors/
    └── matugen.css           # Material Design 3 цвета (генерируется Matugen)
```

#### Особенности swaync
- **Позиция**: правый верхний угол
- **Центр управления**: выдвигается справа, 450px ширины
- **Виджеты**: MPRIS (музыка), DND (не беспокоить), Buttons Grid (кнопки быстрого доступа)
- **Кнопки**: ультра-экономия, кофеин, микрофон, htop, тема, пикер цвета, питание
- **Цвета**: из `colors/matugen.css`

### 7.6. Hyprlock (экран блокировки)

Конфиг: `config/hypr/hyprlock.conf`

```
- Фон: размытый текущие обои (blur_passes = 2)
- Время: крупно (80px) цветом $primary
- Приветствие: "Welcome $USER" цветом $on_surface_variant
- Поле ввода пароля: без рамки, с точками, цвет $surface_container
```

### 7.7. Hypridle (управление питанием)

Конфиг: `config/hypr/hypridle.conf`

```
- 5 мин (600s) → блокировка (hyprlock)
- 11 мин (660s) → выключить экран (dpms off)
- 15 мин (900s) → suspend (systemctl suspend)
```

---

## 8. Скрипты и их назначение

### Hyprland скрипты (`~/.config/hypr/scripts/`)

| Скрипт | Назначение | Хоткей |
|--------|------------|--------|
| `bottomterm.sh` | Запускает tmux с cava + cmatrix + peaclock | Super+` (term-toggle.sh) |
| `floating-cycle.sh` | Циклически переключает окна в плавающий режим | Super+C |
| `keyboard-layout.sh` | Показывает текущую раскладку (US/RU) для waybar | - |
| `layout-notify.sh` | Уведомление о смене раскладки | Автозапуск |
| `minimize-h.sh` | Минимизирует окно вверх (скрывает за верхним краем) | Super+H |
| `postimg-upload.py` | Скриншот → загрузка на postimages.org → ссылка в буфер | Super+Alt+S |
| `resize-all-to-active.sh` | Изменяет размер всех окон под активное | Super+G |
| `rotate-tiled.sh` | Циклически переставляет тайловые окна | Super+D |
| `screen-record.sh` | Запись экрана (wf-recorder) | Super+R |
| `term-toggle.sh` | Переключает bottom-терминал | Super+` |
| `ultralow.sh` | Режим ультра-экономии (root через pkexec) | Super+Shift+P |
| `zoom.sh` | Зум курсора (in/out/reset) | Super+=/Super+-/Super+X |

### Waybar скрипты (`~/.config/waybar/scripts/`)

| Скрипт | Назначение |
|--------|------------|
| `resources.sh` | Мониторинг CPU/RAM/Disk с выпадающим drawer |
| `disk.sh` | Использование диска |
| `color-picker.sh` | Пикер цвета (hyprpicker) |
| `mpris-pill.sh` | Прогресс-бар музыки |

### General скрипты (`~/Scripts/General/`)

| Скрипт | Назначение |
|--------|------------|
| `wallpaper.sh` | Установка обоев + генерация темы Matugen |
| `color-picker.sh` | Копия пикера цвета |
| `ultralow.sh` | Копия ультра-экономии |
| `vpn-connect.sh` | Подключение к VPN |
| `dot-sync.sh` | Синхронизация dotfiles |
| `dir-display.sh` | Отображение директории |

---

## 9. Как это работает: Matugen + генерация цветов

### Полный цикл смены темы

1. Ты запускаешь `wallpaper.sh ~/Pictures/Wallpaper/Everforest/waterfall.png`
2. `awww img` устанавливает обои
3. `matugen image` анализирует изображение и генерирует палитру Material Design 3
4. Matugen обновляет файлы:
   - `~/.config/hypr/colors.conf` — цвета Hyprland
   - `~/.config/waybar/colors.css` — цвета Waybar
   - `~/.config/rofi/colors/matugen.rasi` — цвета Rofi
   - `~/.config/kitty/current-theme.conf` — цвета Kitty
   - `~/.config/swaync/colors/matugen.css` — цвета SwayNC
5. Kitty перезагружается через `pkill -USR1 kitty`
6. Waybar автоматически перезагружается (reload_style_on_change: true)

### Шаблоны Matugen

Matugen использует шаблоны, чтобы знать, куда записывать цвета.
Они находятся в `~/.config/matugen/templates/`.

Вот список используемых шаблонов:

| Шаблон | Создает файл | Описание |
|--------|-------------|----------|
| `colors.conf` | `~/.config/hypr/colors.conf` | Цвета для Hyprland |
| `colors.css` | `~/.config/waybar/colors.css` | Цвета для Waybar |
| `matugen.rasi` | `~/.config/rofi/colors/matugen.rasi` | Цвета для Rofi |
| `Matugen.conf` | `~/.config/kitty/current-theme.conf` | Цвета для Kitty |
| `matugen.css` | `~/.config/swaync/colors/matugen.css` | Цвета для SwayNC |

### Создание шаблонов Matugen

Установи шаблоны Matugen (если еще не установлены):

```bash
# Убедись, что matugen установлен
which matugen

# Создай директорию шаблонов
mkdir -p ~/.config/matugen/templates

# Скопируй конфиги как шаблоны
cp ~/.config/hypr/colors.conf ~/.config/matugen/templates/colors.conf
cp ~/.config/waybar/colors.css ~/.config/matugen/templates/
cp ~/.config/rofi/colors/matugen.rasi ~/.config/matugen/templates/
cp ~/.config/kitty/current-theme.conf ~/.config/matugen/templates/Matugen.conf
cp ~/.config/swaync/colors/matugen.css ~/.config/matugen/templates/
```

После этого `wallpaper.sh` будет обновлять все конфиги автоматически.

### Формат шаблона Matugen

В шаблонах используются переменные вида `{{color}}`.
Пример из `colors.conf`:
```
$primary = rgba({{primary.default.hex}}ff)
$on_primary = rgba({{on-primary.default.hex}}ff)
```

---

## 10. Хоткеи

| Комбинация | Действие |
|-----------|----------|
| **Super + T** | Открыть терминал (kitty) |
| **Super + Q** | Закрыть активное окно |
| **Super + E** | Открыть файловый менеджер (nemo) |
| **Super + F** | Переключить окно в плавающий/тайловый режим |
| **Super + D** | Открыть лаунчер (rofi) |
| **Super + L** | Меню питания (rofi powermenu) |
| **Super + .** | Эмодзи-пикер (rofimoji) |
| **Super + grave (`)** | Переключатель нижнего терминала |
| **Super + C** | Цикл плавающих окон |
| **Super + S** | Скриншот экрана (grimblast copy) |
| **Super + Shift + S** | Скриншот области (grimblast copysave area) |
| **Super + Alt + S** | Скриншот → загрузка на postimages.org |
| **Super + R** | Запись экрана |
| **Super + Shift + R** | Запись области |
| **Super + G** | Выровнять все окна под размер активного |
| **Super + H** | Минимизировать окно (скрыть за верхним краем) |
| **Super + V** | История буфера обмена (cliphist) |
| **Super + Shift + P** | Режим ультра-экономии |
| **Super + =** | Приблизить (zoom in) |
| **Super + -** | Отдалить (zoom out) |
| **Super + X** | Сбросить зум |
| **Super + [1-0]** | Переключиться на рабочий стол |
| **Super + Alt + [1-0]** | Переместить окно на рабочий стол |
| **Super + Стрелки** | Переместить фокус |
| **Super + Shift + Стрелки** | Переместить окно |
| **Super + F1** | Полноэкранный режим |
| Стрелки громкости | Громкость (swayosd) |
| Стрелки яркости | Яркость (swayosd) |
| Кнопки медиа | Play/Pause/Next/Prev |

---

## 11. Запуск и первый вход

### Если используешь DM (Display Manager)
Выбери **Hyprland** в списке сессий.

### Если запускаешь из TTY
Добавь в `~/.bash_profile`:
```bash
if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" = "1" ]; then
  exec Hyprland
fi
```

### После первого входа
1. Проверь, что waybar запустился: `ps aux | grep waybar`
2. Проверь хоткеи: `Super + T` должен открыть kitty
3. Установи обои: `~/Scripts/General/wallpaper.sh ~/Pictures/Wallpaper/Everforest/waterfall.png`
4. Цвета должны автоматически примениться ко всем компонентам

### Проверка всех компонентов
```bash
# Проверить Hyprland
hyprctl version

# Проверить Matugen
matugen --version

# Проверить Awww
awww --version

# Проверить Waybar
waybar --version

# Проверить Rofi
rofi --version

# Проверить Kitty
kitty --version

# Проверить SwayNC
swaync --version
```

---

## 12. Устранение проблем

### ❌ Waybar не запускается
```bash
# Запусти вручную, чтобы увидеть ошибки
waybar

# Проверь config.jsonc на ошибки JSON
jq . ~/.config/waybar/config.jsonc
```

### ❌ Matugen не генерирует цвета
```bash
# Проверь установку
matugen --version

# Запусти вручную
matugen -t scheme-neutral image ~/Pictures/Wallpaper/Everforest/waterfall.png

# Проверь, что есть шаблоны
ls ~/.config/matugen/templates/
```

### ❌ Awww не находит команду
```bash
# Установи awww
yay -S awww-git

# Или используй альтернативу — swww
sudo pacman -S swww
# Замени awww img на swww img в wallpaper.sh
```

### ❌ Скриншоты не работают (grimblast)
```bash
# Установи grimblast
yay -S grimblast-git

# Или используй grim + slurp отдельно
sudo pacman -S grim slurp
```

### ❌ Не работает hyprpicker
```bash
# Установи
yay -S hyprpicker
```

### ❌ Не работает swayosd-client
```bash
# Установи
yay -S swayosd-glibc-git
```

### ❌ Rofi не находит тему
```bash
# Проверь пути
ls ~/.config/rofi/launchers/type-1/style-5.rasi
ls ~/.config/rofi/colors/matugen.rasi

# Запусти с дебагом
rofi -show drun -theme ~/.config/rofi/launchers/type-1/style-5.rasi
```

### ❌ Не работают уведомления (swaync)
```bash
# Проверь, запущен ли сервис
systemctl --user status swaync

# Перезапусти
systemctl --user restart swaync
```

### ❌ Прозрачность Kitty не работает
Kitty использует `background_opacity 0.3`, но для этого нужен композитор.
В Hyprland он уже встроен. Убедись, что в `appearance.conf`:
```conf
decoration {
    blur {
        enabled = true
    }
}
```

### ❌ Ошибки "command not found" в скриптах
Убедись, что все зависимости установлены:
```bash
# Проверка всех зависимостей
for cmd in hyprctl waybar rofi kitty swaync matugen awww grimblast \
  wl-copy cliphist jq playerctl brightnessctl bc wf-recorder slurp; do
  which $cmd || echo "MISSING: $cmd"
done
```

### ❌ Не применяются цвета после смены обоев
```bash
# Перезагрузи waybar вручную
killall waybar && waybar &

# Обнови kitty
pkill -USR1 kitty
```

---

## Структура файлов в репозитории

```
hyprland/
├── README.md                  ← Этот файл (полный тутор)
├── config/
│   ├── hypr/
│   │   ├── hyprland.conf
│   │   ├── colors.conf
│   │   ├── hyprlock.conf
│   │   ├── hypridle.conf
│   │   ├── hyprland-gui.conf
│   │   ├── hyprmod/
│   │   │   └── user_curves.json
│   │   ├── modules/
│   │   │   ├── animations.conf
│   │   │   ├── appearance.conf
│   │   │   ├── binds.conf
│   │   │   ├── envvars.conf
│   │   │   ├── input.conf
│   │   │   ├── misc.conf
│   │   │   ├── monitors.conf
│   │   │   ├── startup.conf
│   │   │   └── windowrules.conf
│   │   └── scripts/
│   │       ├── bottomterm.sh
│   │       ├── floating-cycle.sh
│   │       ├── keyboard-layout.sh
│   │       ├── layout-notify.sh
│   │       ├── minimize-h.sh
│   │       ├── postimg-upload.py
│   │       ├── resize-all-to-active.sh
│   │       ├── rotate-tiled.sh
│   │       ├── screen-record.sh
│   │       ├── term-toggle.sh
│   │       ├── ultralow.sh
│   │       └── zoom.sh
│   ├── kitty/
│   │   ├── kitty.conf
│   │   ├── current-theme.conf
│   │   └── themes/
│   │       └── Matugen.conf
│   ├── rofi/
│   │   ├── config.rasi
│   │   ├── colors/
│   │   │   └── matugen.rasi
│   │   ├── launchers/
│   │   │   ├── emoji/
│   │   │   │   ├── launcher.sh
│   │   │   │   └── grid.rasi
│   │   │   └── type-1/
│   │   │       ├── launcher.sh
│   │   │       ├── style-5.rasi
│   │   │       └── shared/
│   │   │           ├── colors.rasi
│   │   │           └── fonts.rasi
│   │   ├── powermenu/
│   │   │   └── type-2/
│   │   │       ├── powermenu.sh
│   │   │       ├── style-2.rasi
│   │   │       └── shared/
│   │   │           ├── colors.rasi
│   │   │           └── fonts.rasi
│   │   └── scripts/
│   │       ├── launcher_t1
│   │       ├── powermenu_t2
│   │       ├── clipboard
│   │       └── emoji
│   ├── swaync/
│   │   ├── config.json
│   │   ├── style.css
│   │   └── colors/
│   │       └── matugen.css
│   └── waybar/
│       ├── config.jsonc
│       ├── style.css
│       ├── colors.css
│       ├── V23.png
│       └── scripts/
│           ├── color-picker.sh
│           ├── disk.sh
│           ├── mpris-pill.sh
│           └── resources.sh
├── scripts/
│   └── General/
│       └── wallpaper.sh
└── wallpaper/
    ├── Everforest/
    │   └── waterfall.png
    └── wallz/
        └── CatppuccinMocha/
            └── 07.CatppuccinMocha.png
```
