#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir

; ==================== CONFIGURAÇÕES GLOBAIS ====================
global UI_Handle
global STATUS := {em_execucao: false, status_texto: "⏸️ Parado"}
global CONFIG := {}
global POSICOES := {}

; ==================== CARREGAMENTO INICIAL ====================
CarregarConfiguracao()
CriarInterface()

; ==================== TECLAS DE ATALHO ====================

>:: ExitApp()

$[:: {
    if (!STATUS.em_execucao) {
        STATUS.em_execucao := true
        AtualizarStatus("▶️ Iniciando pesca...")
        IniciarPesca()
    }
}

$]:: {
    PararMacro()
}

z:: ConfigurarPosicao("A")
x:: ConfigurarPosicao("S")
c:: ConfigurarPosicao("D")

k:: MostrarCoordenadas()

; ==================== FUNÇÕES PRINCIPAIS ====================

CarregarConfiguracao() {
    global CONFIG, POSICOES
    
    ; Teclas
    CONFIG.vara_tecla := IniRead("config.ini", "Teclas", "VaraTecla", "1")
    CONFIG.isca_tecla := IniRead("config.ini", "Teclas", "IscaTecla", "4")
    CONFIG.canil_tecla := IniRead("config.ini", "Teclas", "CanilTecla", "2")
    
    ; Tempos (ms)
    CONFIG.delay_clique := Integer(IniRead("config.ini", "Tempos", "DelayClique", "15"))
    CONFIG.delay_isca_vara := Integer(IniRead("config.ini", "Tempos", "DelayIscaVara", "700"))
    CONFIG.delay_canil := Integer(IniRead("config.ini", "Tempos", "DelayCanil", "100"))
    
    ; Intervalos (segundos)
    CONFIG.intervalo_comer := Integer(IniRead("config.ini", "Intervalo de Acoes", "IntervaloComer", "300"))
    CONFIG.intervalo_beber := Integer(IniRead("config.ini", "Intervalo de Acoes", "IntervaloBeberAgua", "180"))
    
    ; Failsafe
    CONFIG.failsafe_ciclos := Integer(IniRead("config.ini", "Failsafe", "CiclosFailsafe", "30"))
    
    ; Loot
    CONFIG.loot_reliquias := Integer(IniRead("config.ini", "Loot", "LootReliquias", "1"))
    CONFIG.loot_armas := Integer(IniRead("config.ini", "Loot", "LootArmas", "0"))
    CONFIG.loot_bluesteel := Integer(IniRead("config.ini", "Loot", "LootBlueSteel", "1"))
    
    ; Posições padrão (1920x1080)
    POSICOES.A := {x: 880, y: 580}
    POSICOES.S := {x: 950, y: 640}
    POSICOES.D := {x: 1010, y: 575}
    POSICOES.A_zona := {x1: POSICOES.A.x, y1: POSICOES.A.y, x2: POSICOES.A.x + 25, y2: POSICOES.A.y + 25}
    POSICOES.S_zona := {x1: POSICOES.S.x, y1: POSICOES.S.y, x2: POSICOES.S.x + 25, y2: POSICOES.S.y + 25}
    POSICOES.D_zona := {x1: POSICOES.D.x, y1: POSICOES.D.y, x2: POSICOES.D.x + 25, y2: POSICOES.D.y + 25}
}

CriarInterface() {
    global UI_Handle, CONFIG
    
    myGui := Gui()
    myGui.Opt("+AlwaysOnTop")
    myGui.BackColor := "0D1117"
    
    ; ===== CABEÇALHO =====
    myGui.Add("Text", "c00D4FF h30 w600 Center", "⚙️ DEEPWOKEN FISHING MACRO v2.0")
    myGui.Add("Text", "c6E40AA h2 w600 y+0", "")
    
    ; ===== SEÇÃO: TECLAS =====
    myGui.Add("Text", "c00D4FF h25 w600 y+10", "🎮 CONFIGURAÇÃO DE TECLAS")
    
    myGui.Add("Text", "x10 y+5 w180 h20", "Tecla Vara (equipar):")
    myGui.Add("Edit", "x200 y+0 w50 h20 v_vara", CONFIG.vara_tecla)
    
    myGui.Add("Text", "x10 y+5 w180 h20", "Tecla Isca (Chum):")
    myGui.Add("Edit", "x200 y+0 w50 h20 v_isca", CONFIG.isca_tecla)
    
    myGui.Add("Text", "x10 y+5 w180 h20", "Tecla Cantil (Água):")
    myGui.Add("Edit", "x200 y+0 w50 h20 v_canil", CONFIG.canil_tecla)
    
    ; ===== SEÇÃO: TEMPOS E DELAYS =====
    myGui.Add("Text", "c00D4FF h25 w600 y+15", "⏱️ TEMPOS E DELAYS")
    
    myGui.Add("Text", "x10 y+5 w180 h20", "Delay Cliques (ms):")
    myGui.Add("Edit", "x200 y+0 w50 h20 v_delay_clique", CONFIG.delay_clique)
    myGui.Add("Text", "x260 y+0 w150 h20 c888888", "(⏱️ recomendado: 15)")
    
    myGui.Add("Text", "x10 y+5 w180 h20", "Delay Isca → Vara (ms):")
    myGui.Add("Edit", "x200 y+0 w50 h20 v_delay_isca_vara", CONFIG.delay_isca_vara)
    myGui.Add("Text", "x260 y+0 w200 h20 c888888", "(⏱️ recomendado: 700 - CRÍTICO!)")
    
    myGui.Add("Text", "x10 y+5 w180 h20", "Delay Cantil (ms):")
    myGui.Add("Edit", "x200 y+0 w50 h20 v_delay_canil", CONFIG.delay_canil)
    myGui.Add("Text", "x260 y+0 w150 h20 c888888", "(padrão: 100)")
    
    ; ===== SEÇÃO: INTERVALOS DE AÇÕES =====
    myGui.Add("Text", "c00D4FF h25 w600 y+15", "🔄 INTERVALOS DE AÇÕES (segundos)")
    
    myGui.Add("Text", "x10 y+5 w180 h20", "Intervalo Comer (s):")
    myGui.Add("Edit", "x200 y+0 w50 h20 v_intervalo_comer", CONFIG.intervalo_comer)
    myGui.Add("Text", "x260 y+0 w180 h20 c888888", "(⏱️ recomendado: 300)")
    
    myGui.Add("Text", "x10 y+5 w180 h20", "Intervalo Beber (s):")
    myGui.Add("Edit", "x200 y+0 w50 h20 v_intervalo_beber", CONFIG.intervalo_beber)
    myGui.Add("Text", "x260 y+0 w180 h20 c888888", "(⏱️ recomendado: 180)")
    
    myGui.Add("Text", "x10 y+5 w180 h20", "Failsafe Ciclos:")
    myGui.Add("Edit", "x200 y+0 w50 h20 v_failsafe", CONFIG.failsafe_ciclos)
    myGui.Add("Text", "x260 y+0 w150 h20 c888888", "(padrão: 30)")
    
    ; ===== SEÇÃO: FUNÇÕES AUTOMÁTICAS =====
    myGui.Add("Text", "c00D4FF h25 w600 y+15", "🤖 FUNÇÕES AUTOMÁTICAS")
    
    myGui.Add("Checkbox", "x10 y+5 w300 Checked v_auto_beber", "✓ Auto-Beber Água")
    myGui.Add("Checkbox", "x10 y+5 w300 Checked v_auto_defesa", "✓ Auto-Defesa em Combate")
    myGui.Add("Checkbox", "x10 y+5 w300 Checked v_loot_reliquias", "✓ Auto-Loot Relíquias")
    myGui.Add("Checkbox", "x10 y+5 w300 v_loot_armas", "✗ Auto-Loot Armas")
    myGui.Add("Checkbox", "x10 y+5 w300 Checked v_loot_bluesteel", "✓ Auto-Loot BlueSteel")
    
    ; ===== SEÇÃO: POSIÇÕES =====
    myGui.Add("Text", "c00D4FF h25 w600 y+15", "📍 CONFIGURAÇÃO DE POSIÇÕES")
    
    myGui.Add("Text", "x10 y+5 w200 h20", "Pressione Z/X/C para configurar:")
    myGui.Add("Text", "x10 y+5 w600 h20 c888888", "Z = Esquerda (A) | X = Centro (S) | C = Direita (D)")
    myGui.Add("Button", "x10 y+5 w80 h25 v_btn_coords", "Ver Coords (K)")
    
    ; ===== SEÇÃO: BOTÕES =====
    myGui.Add("Button", "x10 y+15 w120 h35 c00D4FF v_btn_iniciar", "▶️  INICIAR [[]")
    myGui.Add("Button", "x135 y+0 w120 h35 cFF6B00 v_btn_parar", "⏹️  PARAR []")
    myGui.Add("Button", "x260 y+0 w100 h35 cCC0000 v_btn_sair", "❌  SAIR")
    
    ; ===== SEÇÃO: STATUS =====
    myGui.Add("Text", "c6E40AA h2 w600 y+10", "")
    myGui.Add("Text", "x10 y+5 w600 h30 c00FF00 v_status", STATUS.status_texto)
    myGui.Add("Text", "x10 y+5 w600 h20 c888888", "Posições: A (Z) | S (X) | D (C) | Ver coords (K)")
    
    myGui.Show("w620 h750 +AlwaysOnTop", "Deepwoken Fishing Macro")
    
    UI_Handle := myGui
}

AtualizarStatus(texto) {
    global STATUS, UI_Handle
    STATUS.status_texto := texto
    if (UI_Handle) {
        try UI_Handle["_status"].Value := texto
    }
}

IniciarPesca() {
    global CONFIG, POSICOES, STATUS
    
    if (!STATUS.em_execucao) return
    
    AtualizarStatus("🎣 Preparando pesca...")
    
    ; Liberar TODAS as teclas - CRÍTICO para evitar bug de andar
    send("{a up}{s up}{d up}{w up}")
    sleep(100)
    
    ; Reset com Shift
    send("{shift down}")
    sleep(300)
    send("{shift up}")
    sleep(300)
    
    AtualizarStatus("🪝 Equipando isca...")
    
    ; PASSO 1: Equipar isca
    send("{" CONFIG.isca_tecla " down}")
    sleep(50)
    send("{" CONFIG.isca_tecla " up}")
    
    ; PASSO 2: Esperar o tempo configurado entre isca e vara
    AtualizarStatus("⏳ Aguardando " (CONFIG.delay_isca_vara/1000) "s...")
    sleep(CONFIG.delay_isca_vara)
    
    AtualizarStatus("🎣 Jogando vara (M1 Click)...")
    
    ; PASSO 3: Clicar M1 para jogar vara
    send("{click}")
    sleep(200)
    
    AtualizarStatus("🐟 Detectando peixes...")
    sleep(500)
    
    ; PASSO 4: Iniciar detecção
    DetectarEReagir()
}

DetectarEReagir() {
    global CONFIG, POSICOES, STATUS
    
    local failsafe := CONFIG.failsafe_ciclos
    local detectado := false
    
    loop {
        if (!STATUS.em_execucao) break
        
        ; ZONA A (Esquerda)
        PixelSearch(&x, &y, POSICOES.A_zona.x1, POSICOES.A_zona.y1, POSICOES.A_zona.x2, POSICOES.A_zona.y2, 0xFFFFFF, 90)
        if (ErrorLevel = 0) {
            failsafe := CONFIG.failsafe_ciclos
            LibertarTodasAsTeclas()
            send("{a down}")
            AtualizarStatus("⬅️  Puxando ESQUERDA (A) - Failsafe: " failsafe)
            detectado := true
        }
        
        ; ZONA S (Centro)
        PixelSearch(&x, &y, POSICOES.S_zona.x1, POSICOES.S_zona.y1, POSICOES.S_zona.x2, POSICOES.S_zona.y2, 0xFFFFFF, 90)
        if (ErrorLevel = 0) {
            failsafe := CONFIG.failsafe_ciclos
            LibertarTodasAsTeclas()
            send("{s down}")
            AtualizarStatus("⬇️  Puxando CENTRO (S) - Failsafe: " failsafe)
            detectado := true
        }
        
        ; ZONA D (Direita)
        PixelSearch(&x, &y, POSICOES.D_zona.x1, POSICOES.D_zona.y1, POSICOES.D_zona.x2, POSICOES.D_zona.y2, 0xFFFFFF, 90)
        if (ErrorLevel = 0) {
            failsafe := CONFIG.failsafe_ciclos
            LibertarTodasAsTeclas()
            send("{d down}")
            AtualizarStatus("➡️  Puxando DIREITA (D) - Failsafe: " failsafe)
            detectado := true
        }
        
        if (!detectado) {
            LibertarTodasAsTeclas()
            failsafe--
            AtualizarStatus("⏳ Esperando peixe... Failsafe: " failsafe "/" CONFIG.failsafe_ciclos)
        }
        
        detectado := false
        sleep(CONFIG.delay_clique)
        
        if (failsafe <= 0) {
            AtualizarStatus("♻️  Recast - Repescando...")
            LibertarTodasAsTeclas()
            sleep(300)
            
            if (STATUS.em_execucao) {
                IniciarPesca()
            }
            break
        }
    }
}

LibertarTodasAsTeclas() {
    send("{a up}{s up}{d up}{w up}")
    sleep(20)
}

ConfigurarPosicao(tipo) {
    global POSICOES
    
    ToolTip("🖱️ Mova o mouse para a posição " tipo " (luz branca) e pressione " tipo " novamente", 960, 50)
    
    KeyWait tipo
    MouseGetPos(&x, &y)
    
    switch tipo {
        case "A":
            POSICOES.A := {x: x, y: y}
            POSICOES.A_zona := {x1: x, y1: y, x2: x + 25, y2: y + 25}
            ToolTip("✓ Posição A configurada em: " x " x " y, 960, 50)
        case "S":
            POSICOES.S := {x: x, y: y}
            POSICOES.S_zona := {x1: x, y1: y, x2: x + 25, y2: y + 25}
            ToolTip("✓ Posição S configurada em: " x " x " y, 960, 50)
        case "D":
            POSICOES.D := {x: x, y: y}
            POSICOES.D_zona := {x1: x, y1: y, x2: x + 25, y2: y + 25}
            ToolTip("✓ Posição D configurada em: " x " x " y, 960, 50)
    }
    
    SetTimer(() => ToolTip(), 3000)
}

MostrarCoordenadas() {
    global POSICOES
    
    msg := "📍 COORDENADAS ATUAIS:\n\n"
    msg .= "A (Esquerda): " POSICOES.A.x " x " POSICOES.A.y "\n"
    msg .= "S (Centro):   " POSICOES.S.x " x " POSICOES.S.y "\n"
    msg .= "D (Direita):  " POSICOES.D.x " x " POSICOES.D.y
    
    ToolTip(msg, 100, 100)
    SetTimer(() => ToolTip(), 5000)
}

PararMacro() {
    global STATUS
    
    STATUS.em_execucao := false
    LibertarTodasAsTeclas()
    AtualizarStatus("⏸️  Macro parado")
    ToolTip("⏸️  Macro parado com sucesso", 960, 50)
    SetTimer(() => ToolTip(), 2000)
}

; ==================== FIM ====================
