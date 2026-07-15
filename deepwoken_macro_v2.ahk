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
    
    ; Função auxiliar criada para ignorar os comentários (;) e espaços vazios
    LerIni(secao, chave, padrao) {
        valor := IniRead("config.ini", secao, chave, padrao)
        return Trim(StrSplit(valor, ";")[1]) ; Corta no ";" e limpa os espaços
    }
    
    ; Teclas
    CONFIG.vara_tecla := LerIni("Teclas", "VaraTecla", "1")
    CONFIG.isca_tecla := LerIni("Teclas", "IscaTecla", "4")
    CONFIG.canil_tecla := LerIni("Teclas", "CanilTecla", "2")
    
    ; Tempos (ms)
    CONFIG.delay_clique := Integer(LerIni("Tempos", "DelayClique", "15"))
    CONFIG.delay_isca_vara := Integer(LerIni("Tempos", "DelayIscaVara", "700"))
    CONFIG.delay_canil := Integer(LerIni("Tempos", "DelayCanil", "100"))
    
    ; Intervalos (segundos)
    CONFIG.intervalo_comer := Integer(LerIni("Intervalo de Acoes", "IntervaloComer", "300"))
    CONFIG.intervalo_beber := Integer(LerIni("Intervalo de Acoes", "IntervaloBeberAgua", "180"))
    
    ; Failsafe
    CONFIG.failsafe_ciclos := Integer(LerIni("Failsafe", "CiclosFailsafe", "30"))
    
    ; Loot
    CONFIG.loot_reliquias := Integer(LerIni("Loot", "LootReliquias", "1"))
    CONFIG.loot_armas := Integer(LerIni("Loot", "LootArmas", "0"))
    CONFIG.loot_bluesteel := Integer(LerIni("Loot", "LootBlueSteel", "1"))
    
    ; Posições padrão (1920x1080)
    POSICOES.A := {x: 880, y: 580}
    POSICOES.S := {x: 950, y: 640}
    POSICOES.D := {x: 1010, y: 575}
    POSICOES.A_zona := {x1: POSICOES.A.x, y1: POSICOES.A.y, x2: POSICOES.A.x + 25, y2: POSICOES.A.y + 25}
    POSICOES.S_zona := {x1: POSICOES.S.x, y1: POSICOES.S.y, x2: POSICOES.S.x + 25, y2: POSICOES.S.y + 25}
    POSICOES.D_zona := {x1: POSICOES.D.x, y1: POSICOES.D.y, x2: POSICOES.D.x + 25, y2: POSICOES.D.y + 25}
}

CriarInterface() {
    global UI_Handle, CONFIG, STATUS
    
    myGui := Gui("-MaximizeBox -MinimizeBox", "Deepwoken Fishing Macro")
    myGui.Opt("+AlwaysOnTop")
    myGui.BackColor := "1A1B26" ; Fundo escuro moderno
    myGui.SetFont("s10 cC0CAF5", "Segoe UI") ; Fonte limpa e legível
    
    ; ===== CABEÇALHO =====
    myGui.SetFont("s16 Bold c7AA2F7") 
    myGui.Add("Text", "x0 y15 w780 Center", "⚙️ DEEPWOKEN FISHING MACRO v2.0")
    myGui.SetFont("s10 Norm cC0CAF5")
    
    ; ================= COLUNA 1 (Esquerda) =================
    myGui.SetFont("Bold cBB9AF7")
    myGui.Add("Text", "x25 y65 w220", "🎮 CONFIGURAÇÃO DE TECLAS")
    myGui.SetFont("Norm cC0CAF5")
    myGui.Add("Text", "x25 y95 w120", "Vara (equipar):")
    myGui.Add("Edit", "x145 y90 w60 Center v_vara Background24283B cWhite", CONFIG.vara_tecla)
    myGui.Add("Text", "x25 y130 w120", "Isca (Chum):")
    myGui.Add("Edit", "x145 y125 w60 Center v_isca Background24283B cWhite", CONFIG.isca_tecla)
    myGui.Add("Text", "x25 y165 w120", "Cantil (Água):")
    myGui.Add("Edit", "x145 y160 w60 Center v_canil Background24283B cWhite", CONFIG.canil_tecla)
    
    myGui.SetFont("Bold cBB9AF7")
    myGui.Add("Text", "x25 y215 w220", "⏱️ TEMPOS E DELAYS")
    myGui.SetFont("Norm cC0CAF5")
    myGui.Add("Text", "x25 y245 w120", "Cliques (ms):")
    myGui.Add("Edit", "x145 y240 w60 Center v_delay_clique Background24283B cWhite", CONFIG.delay_clique)
    myGui.Add("Text", "x25 y280 w120", "Isca → Vara (ms):")
    myGui.Add("Edit", "x145 y275 w60 Center v_delay_isca_vara Background24283B cWhite", CONFIG.delay_isca_vara)
    myGui.Add("Text", "x25 y315 w120", "Cantil (ms):")
    myGui.Add("Edit", "x145 y310 w60 Center v_delay_canil Background24283B cWhite", CONFIG.delay_canil)
    
    ; ================= COLUNA 2 (Centro) =================
    myGui.SetFont("Bold c9ECE6A")
    myGui.Add("Text", "x280 y65 w220", "🔄 INTERVALOS (segundos)")
    myGui.SetFont("Norm cC0CAF5")
    myGui.Add("Text", "x280 y95 w120", "Comer:")
    myGui.Add("Edit", "x395 y90 w60 Center v_intervalo_comer Background24283B cWhite", CONFIG.intervalo_comer)
    myGui.Add("Text", "x280 y130 w120", "Beber Água:")
    myGui.Add("Edit", "x395 y125 w60 Center v_intervalo_beber Background24283B cWhite", CONFIG.intervalo_beber)
    myGui.Add("Text", "x280 y165 w120", "Failsafe (Ciclos):")
    myGui.Add("Edit", "x395 y160 w60 Center v_failsafe Background24283B cWhite", CONFIG.failsafe_ciclos)
    
    myGui.SetFont("Bold c9ECE6A")
    myGui.Add("Text", "x280 y215 w220", "🤖 FUNÇÕES AUTOMÁTICAS")
    myGui.SetFont("Norm cC0CAF5")
    myGui.Add("Checkbox", "x280 y245 w220 Checked v_auto_beber", "Auto-Beber Água")
    myGui.Add("Checkbox", "x280 y275 w220 Checked v_auto_defesa", "Auto-Defesa em Combate")
    myGui.Add("Checkbox", "x280 y305 w110 Checked v_loot_reliquias", "Loot Relíquias")
    myGui.Add("Checkbox", "x395 y305 w110 Checked v_loot_bluesteel", "Loot BlueSteel")
    myGui.Add("Checkbox", "x280 y335 w220 v_loot_armas", "Loot Armas")
    
    ; ================= COLUNA 3 (Direita) =================
    myGui.SetFont("Bold cE0AF68")
    myGui.Add("Text", "x530 y65 w230", "📍 POSIÇÕES DE PESCA")
    myGui.SetFont("s9 c565F89")
    myGui.Add("Text", "x530 y90 w230", "Z = Esquerda | X = Centro | C = Direita")
    myGui.SetFont("s10 cC0CAF5")
    myGui.Add("Button", "x530 y115 w220 h30 v_btn_coords", "🔍 Ver Coordenadas (K)")
    
    myGui.SetFont("Bold cE0AF68")
    myGui.Add("Text", "x530 y180 w230", "🎮 CONTROLE DO MACRO")
    myGui.SetFont("Norm cC0CAF5")
    myGui.Add("Button", "x530 y210 w105 h45 cBlack v_btn_iniciar", "▶ INICIAR [")
    myGui.Add("Button", "x645 y210 w105 h45 cBlack v_btn_parar", "⏹ PARAR ]")
    myGui.Add("Button", "x530 y265 w220 h35 cBlack v_btn_sair", "❌ FECHAR E SAIR")
    
    ; ===== RODAPÉ DE STATUS =====
    myGui.Add("Text", "x25 y385 w730 h2 0x10") ; Linha divisória horizontal
    myGui.SetFont("Bold s12 c9ECE6A")
    myGui.Add("Text", "x25 y400 w730 Center v_status", STATUS.status_texto)
    
    myGui.Show("w780 h450")
    UI_Handle := myGui
}

AtualizarStatus(texto) {
    global STATUS, UI_Handle
    STATUS.status_texto := texto
    if (UI_Handle) {
        try UI_Handle["status"].Value := texto
    }
}

IniciarPesca() {
    global CONFIG, POSICOES, STATUS
    
    if (!STATUS.em_execucao) {
        return
    }
    
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
    
    Loop {
        if (!STATUS.em_execucao) {
            break
        }
        
        ; ZONA A (Esquerda)
        resultado := PixelSearch(&x, &y, POSICOES.A_zona.x1, POSICOES.A_zona.y1, POSICOES.A_zona.x2, POSICOES.A_zona.y2, 0xFFFFFF, 90)
        if (resultado = 0) {
            failsafe := CONFIG.failsafe_ciclos
            LibertarTodasAsTeclas()
            send("{a down}")
            AtualizarStatus("⬅️  Puxando ESQUERDA (A) - Failsafe: " failsafe)
            detectado := true
        }
        
        ; ZONA S (Centro)
        resultado := PixelSearch(&x, &y, POSICOES.S_zona.x1, POSICOES.S_zona.y1, POSICOES.S_zona.x2, POSICOES.S_zona.y2, 0xFFFFFF, 90)
        if (resultado = 0) {
            failsafe := CONFIG.failsafe_ciclos
            LibertarTodasAsTeclas()
            send("{s down}")
            AtualizarStatus("⬇️  Puxando CENTRO (S) - Failsafe: " failsafe)
            detectado := true
        }
        
        ; ZONA D (Direita)
        resultado := PixelSearch(&x, &y, POSICOES.D_zona.x1, POSICOES.D_zona.y1, POSICOES.D_zona.x2, POSICOES.D_zona.y2, 0xFFFFFF, 90)
        if (resultado = 0) {
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
    
    msg := "📍 COORDENADAS ATUAIS:`n`n"
    msg .= "A (Esquerda): " POSICOES.A.x " x " POSICOES.A.y "`n"
    msg .= "S (Centro):   " POSICOES.S.x " x " POSICOES.S.y "`n"
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
