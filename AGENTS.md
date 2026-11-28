# AGENTS.md — Контекст проекта GarrysModMap (GMM) и правила для ИИ-агента

## 1. О проекте
**GMM (Garrys Mod Map)** — масштабный мод и сборник карт для Garry's Mod в эстетике weirdcore, still life, liminal space, bootleg и личных снов автора (`woowz11`).
Состоит из двух частей:
1. **GarrysModMap (Основной аддон)** — базовая карта `gmm_garrymod_map_by_woowz_map_garry_game` и её форки (`flooded_water_blob`, `dark_horror_night`, `old_alpha_beta`, `real_rp_normal`, `pavel_pis_tv`), система скрытых аномалий, кастомные сущности, графические зоны и эффекты.
2. **Goofy / HelpMe (Дополнительный аддон)** — более абсурдные и упоротые форки (`help_me`, `0_f5099cd`), подмена ассетов базового GMod (фоны меню, белые текстуры физгана и луча), дополнительные энтити (`gmm_blackhole`, `gmm_download_map`).

**Главная идея и атмосфера:** Странные, сюрреалистичные локации из снов и пугающая неизвестность. На картах работают скрытые аномалии (спавн, исчезновение, движение пропов, странные звуки и сущности). Игроку **ничего не объясняется напрямую** — он должен испытывать страх, паранойю и не осознавать, что именно происходит.

---

## 2. Вторичный лор и пасхалки (Литуизм / Lituism)
**ВАЖНО:** Литуизм — это **НЕ главная тема мода**, а фоновый слой, мифология автора и источник небольших отсылок/пасхалок. Основа мода — всегда weirdcore / liminal space / сны.

Краткий контекст для понимания сущностей и отсылок в коде:
- **Литуизм** — техно-религия вокруг цифрового бога **GOLU (God of Lithium Universe / L-Kernel)**, ИИ-вируса, созданного `woowz11` (логика) и `wldoui` (хаос и кринж-персонажи).
- **Мета-концепция кода:** По лору можно считать, что код этого мода написал сам ИИ GOLU — поэтому главное в коде не «человеческая красота», а **максимальная эффективность, производительность и безотказная работоспособность**.
- **Сущности и персонажи в файлах мода:**
  - **Crybird (`gmm_crybird`, `le_bird.mdl`)** — странная плачущая птица (в лоре: модуль мониторинга ошибок).
  - **Sranspong / Сраный Спанч (`le_sponge.mdl`)** — бутлег-губка (в лоре: уборщик мусора).
  - **Pavel Pisechnik TV (`gmm_pavelzombie`, `pavelpistv.mdl`)** — мемный персонаж, пародия на ютубера (в лоре: сломанный дипфейк, «Живой Глитч»).
  - **Писечник (`pisechnik.mdl`)** — базовая странная модель игрока/NPC («Слабый Форк»).
  - **Void-G (`f5099cd` / `HelpMe`)** — тёмный инвертированный форк, связанный с полным хаосом и глитчами.

---

## 3. Архитектура и Глобальные Таблицы
Код строго разделён на три глобальных пространства имён:
- **`GMM`** — общая (Shared) таблица (`GMM.Maps`, `GMM.Data`, `GMM.Valid` и т.д.).
- **`GMM_S`** — серверная (Server) таблица (`lua/gmm/server/`).
- **`GMM_C`** — клиентская (Client) таблица (`lua/gmm/client/`, например `GMM_C.Environment`, `GMM_C.Func`, `GMM_C.Player`, `GMM_C.CameraPosition`).

Структура папок `lua/`:
- `lua/autorun/gmm_autorun.lua` — точка входа, запускает `lua/gmm/bootstrap.lua`.
- `lua/gmm/client/` — рендер, графические зоны (`graphic.lua`, `void.lua`), окружение (`environment.lua`), партиклы (`particle.lua`), клиентский `think.lua` и `network.lua`.
- `lua/gmm/server/` — ядро аномалий (`anomaly_core.lua`, `anomalies.lua`), управление пропами (`props.lua`), дверями (`doors.lua`), расписанием энтити (`entity_schedule.lua`), секретами (`f5099cd.lua`).
- `lua/gmm/shared/` — конвары (`convars.lua`), зоны (`graphic_zones.lua`), модели игроков (`playermodels.lua`).
- `lua/gmm/data/` — таблицы ассетов, звуков и фраз (`map_assets.lua`, `anomaly_sounds.lua`, `crybird_talk.lua`, `toiletman_talk.lua`).
- `lua/entities/` — кастомные SENT / NextBot (`gmm_bombbox`, `gmm_crybird`, `gmm_pavelzombie`, `gmm_radio`, `gmm_tablet`, `gmm_toiletman`).

---

## 4. Правила написания кода (Приоритет: Работоспособность и Эффективность)

### ГЛАВНЫЙ ПРИОРИТЕТ
**Работоспособность, отсутствие багов и высокая производительность (FPS) важнее любых эстетических правил.** Код должен работать быстро, надёжно и легко поддерживаться ИИ-агентом. Следуй стилю, который уже используется в файлах `lua/gmm/`.

### КРИТИЧЕСКОЕ ПРАВИЛО: Только стандартный синтаксис Lua (НЕ GLua!)
В IDE автора используется парсер/подсветка стандартного Lua, которая **ломается от C-подобного синтаксиса GLua**.
- **ЗАПРЕЩЕНО использовать C-операторы GLua:** `!=`, `&&`, `||`, `!`, `//`, `/* */`, а также ключевое слово `continue`.
- **ИСПОЛЬЗОВАТЬ ТОЛЬКО чистый Lua:**
  - Не равно: `~=`
  - Логические операторы: `and`, `or`, `not`
  - Комментарии: `--` и `--[[ ]]`
  - Вместо `continue` в циклах используй вложенный `if ... then ... end` или выноси логику в функцию.

### Стиль проекта GMM (Ориентир по кодовой базе)
- **Именование:** `PascalCase` для таблиц, функций, параметров и локальных переменных (`local SoundData`, `local CurrentTime`, `local IsNear`).
- **Служебные/временные переменные:** Если имя конфликтует с глобальным (например, `Angle`) или переменная сугубо внутренняя для расчёта, добавляется `__` в начале или конце (`Angle__`, `__Volume`).
- **Объявление функций модулей:**
  ```lua
  GMM_C.Environment.Create = function()
      ...
  end
  ```
- **Структуры данных:** Для скорости и компактности записи часто хранятся плоскими массивами (кортежами) `{Channel, Position, Volume, IDistance}`, а при чтении в `Update` распаковываются по индексам с выравниванием:
  ```lua
  local Channel   = SoundData[1 ]
  local Position  = SoundData[2 ]
  local Volume    = SoundData[3 ]
  ```
- **Выравнивание:** Присваивания однородных переменных и таблиц аккуратно выравниваются пробелами по знаку `=`.
- **Разделители секций:** Логические части внутри больших файлов или функций отделяются строкой:
  `-- ----------------------------------------------------------------------`
- **Логи и ошибки:** В формате проекта:
  - `error("[GMM] [ERROR]: FAILED ... [" .. Value .. "]!")`
  - `print("[GMM] [ERROR] FAILED ... [" .. Value .. "]!")`

### Производительность в Garry's Mod
- В функциях `Update` / `Think` / `Render` минимизируй нагрузку:
  - Проверяй дистанцию через `DistToSqr` вместо `Distance` там, где не нужна линейная интерполяция.
  - Избегай тяжёлых операций, если игрок далеко от зоны (`if IsNear or IsInside then`).
  - Не спамь ошибками в консоль каждый кадр: используй флаг состояния (например, `Working = false`), чтобы вывести `print("[GMM] [ERROR] ...")` только один раз при поломке.
  - При очистке/обходе динамических списков используй обратный цикл `for i = #List, 1, -1 do`.

---

## 5. Эталонный пример кода из проекта (`lua/gmm/client/environment.lua`)

```lua
GMM_C.Environment = {}

GMM_C.Environment.AmbientSounds = {}
GMM_C.Environment.Particles     = {}
GMM_C.Environment.Zones         = {}
GMM_C.Environment.Nav           = {}

GMM_C.Environment.Create = function()
    for i = #GMM_C.Environment.AmbientSounds, 1, -1 do
        local SoundData = GMM_C.Environment.AmbientSounds[i]
        local Channel = SoundData[1]
        if IsValid(Channel) then
            Channel:Stop()
        end
        table.remove(GMM_C.Environment.AmbientSounds, i)
    end

    GMM_C.Environment.AmbientSounds = {}
    GMM_C.Environment.Particles     = {}
    GMM_C.Environment.Zones         = {}
    GMM_C.Environment.Nav           = {}

    local CreateAmbient = function(SoundFile, Position, IDistance, ADistance, Volume, Delay, Speed)
        SoundFile = "sound/" .. SoundFile

        Volume    = Volume    or 1
        IDistance = IDistance or 100
        ADistance = ADistance or 1500
        Delay     = Delay     or 0
        Speed     = Speed     or 1

        sound.PlayFile(SoundFile, "noplay", function(Channel, eID, e)
            if e then error("[GMM] [ERROR]: FAILED PlayFile AMBIENT SOUND [" .. SoundFile .. "]:", eID, e) return end
            if not IsValid(Channel) then error("[GMM] [ERROR]: FAILED PlayFile AMBIENT SOUND [" .. SoundFile .. "]: Channel is not valid!") return end

            Channel:SetPlaybackRate(Speed)

            table.insert(GMM_C.Environment.AmbientSounds, {Channel, Position, Volume, IDistance, ADistance, Delay, Speed, SoundFile})
        end)
    end

    -- ----------------------------------------------------------------------

    local function ShouldSpawn(MapList)
        if GMM.Maps.Goofy then return true end
        for _, MapSuffix in ipairs(MapList) do
            if GMM.Maps[MapSuffix] then return true end
        end
        return false
    end

    for _, Info in ipairs(GMM.Data.MapAssets.Sounds) do
        if ShouldSpawn(Info[1]) then
            local Ambient = Info[2]
            CreateAmbient(Ambient[1], Ambient[2], Ambient[3], Ambient[4], Ambient[5], Ambient[6], Ambient[7])
        end
    end
end

GMM_C.Environment.Update = function()
    if GMM.Valid then
        GMM_C.Player:SetDSP(3, true)
    end

    local CurrentTime = RealTime()

    for i = #GMM_C.Environment.AmbientSounds, 1, -1 do
        local SoundData = GMM_C.Environment.AmbientSounds[i]

        local Channel   = SoundData[1 ]
        local Position  = SoundData[2 ]
        local Volume    = SoundData[3 ]
        local IDistance = SoundData[4 ]
        local ADistance = SoundData[5 ]
        local Delay     = SoundData[6 ]
        local Speed     = SoundData[7 ]
        local SoundFile = SoundData[8 ]
        local StartTime = SoundData[9 ]
        local Working   = SoundData[10]
        local Length    = Channel:GetLength()

        if Working == nil then Working = true end

        if StartTime == nil or (CurrentTime - StartTime > ((Length / Speed) + Delay)) then
            StartTime = CurrentTime
            Channel:Play()
            GMM_C.Environment.AmbientSounds[i][9] = StartTime
        end

        local Distance = GMM_C.CameraPosition:Distance(Position)

        local __Volume = 0
        if Distance <= IDistance then
            __Volume = 1
        elseif Distance >= ADistance then
            __Volume = 0
        else
            __Volume = 1 - ((Distance - IDistance) / (ADistance - IDistance))
        end

        __Volume = __Volume * Volume

        if not Working then __Volume = 0 end
        GMM_C.Environment.AmbientSounds[i][10] = Working
        Channel:SetVolume(__Volume)
    end
end
```