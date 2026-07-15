# 🎣 Deepwoken Fishing Macro v2.0

Macro automatizado de pesca para **Deepwoken** com interface gráfica moderna, sistema de isca otimizado e todas as funções configuráveis.

## ✨ Funcionalidades

- ✅ **Pesca Automática** - Detecção e reação automática aos peixes (esquerda, centro, direita)
- ✅ **Sistema de Isca Perfeito** - Equipa isca e joga vara com delay configurável (0.7s recomendado)
- ✅ **M1 Click** - Usa clique do mouse para jogar vara (não depende de tecla)
- ✅ **Auto-Loot** - Coleta itens de baús (Relíquias, Armas, BlueSteel)
- ✅ **Auto-Hidratação** - Bebe água automaticamente quando necessário
- ✅ **Auto-Defesa** - Ativa defesa automática em combate
- ✅ **Proteção contra Morte** - Detecta morte e reinicia
- ✅ **Interface Moderna** - GUI horizontal com indicadores de tempo recomendado
- ✅ **Bug de Andar Corrigido** - Liberação correta de todas as teclas
- ✅ **100% Configurável** - Todas as funções são opcionais

## 📋 Requisitos

- **AutoHotkey v2.0+** - [Download](https://www.autohotkey.com/)
- **Deepwoken** instalado e aberto em 1920x1080 (recomendado)
- **Windows 10/11**

## 🚀 Como Usar

### 1️⃣ Preparação Inicial

1. Extraia todos os arquivos em uma pasta
2. Abra o arquivo `config.ini` e configure:
   ```ini
   [Teclas]
   VaraTecla=1          ; Tecla para equipar vara na mão
   IscaTecla=4          ; Tecla da isca (Chum) no inventário
   CanilTecla=2         ; Tecla do cantil de água
   
   [Tempos]
   DelayIscaVara=700    ; Espera entre clicar isca e jogar vara (ms)
   ```

3. No jogo, segure a **vara de pesca** na mão
4. Coloque **isca (Chum)** em um slot de atalho (ex: 4)
5. Coloque **cantil de água** em um slot de atalho (ex: 2)

### 2️⃣ Configurar Posições (IMPORTANTE!)

O macro precisa saber para onde puxar o peixe. Há 3 zonas:

- **A (Esquerda)** → Luz branca à esquerda
- **S (Centro)** → Luz branca no centro
- **D (Direita)** → Luz branca à direita

**Para configurar:**

1. Abra o macro (`deepwoken_macro_v2.ahk`)
2. Pressione **Z** e posicione o mouse na zona **A** (esquerda) da tela
3. Pressione **Z** novamente para confirmar
4. Repita para **X** (zona S) e **C** (zona D)
5. Pressione **K** para verificar as coordenadas

### 3️⃣ Iniciar a Pesca

- **`[`** = Iniciar pesca
- **`]`** = Parar pesca
- **`>`** (Shift+.) = Sair do macro

## ⌨️ Atalhos Completos

| Tecla | Ação |
|-------|------|
| `[` | ▶️ Iniciar pesca |
| `]` | ⏹️ Parar pesca |
| `>` | ❌ Sair do programa |
| `Z` | 📝 Configurar posição A (esquerda) |
| `X` | 📝 Configurar posição S (centro) |
| `C` | 📝 Configurar posição D (direita) |
| `K` | 📋 Mostrar coordenadas atuais |

## 🎮 Fluxo de Pesca

```
1. Pressiona [  → Macro inicia
   ↓
2. Equipa isca (clica na tecla 4)
   ↓
3. Espera 700ms (configurável)
   ↓
4. Clica M1 (joga vara)
   ↓
5. Detecta luz branca (A/S/D)
   ↓
6. Puxa para o lado correto
   ↓
7. Pesca termina → volta ao passo 2
```

## ⚙️ Configuração do config.ini

### Teclas
```ini
[Teclas]
VaraTecla=1          ; Equipar vara (1-9, não é para jogar)
IscaTecla=4          ; Isca que será equipada
CanilTecla=2         ; Cantil de água
```

### Tempos (milissegundos)
```ini
[Tempos]
DelayClique=15
; ⏱️ Recomendado: 15ms
; Quanto tempo espera entre cada detecção de cor
; Valores: 5-20 (mais baixo = mais responsivo, mais CPU)
; Se ficar andando, aumente para 30-50

DelayIscaVara=700
; ⏱️ Recomendado: 700ms (IMPORTANTE!)
; Tempo entre clicar na isca e clicar para jogar a vara
; Você clica isca, espera esse tempo, depois clica M1
; Valores: 500-1000ms (testado: 700ms funciona perfeito)

DelayCanil=100
; Padrão: 100ms
; Tempo para usar o cantil/caneca de água
```

### Intervalos (segundos)
```ini
[Intervalo de Acoes]
IntervaloComer=300
; ⏱️ Recomendado: 300 segundos (5 minutos)

IntervaloBeberAgua=180
; ⏱️ Recomendado: 180 segundos (3 minutos)
```

### Failsafe
```ini
[Failsafe]
CiclosFailsafe=30
; Quantos ciclos sem detectar peixe antes de recast
```

### Loot
```ini
[Loot]
LootReliquias=1      ; 1 = ativar, 0 = desativar
LootArmas=0
LootBlueSteel=1
```

## 🔧 Solução de Problemas

### ❌ Personagem fica andando após pesca

**Solução:**
- Aumente o `DelayClique` para 30-50ms
- Verifique se as posições (A, S, D) estão corretas
- Pressione `]` para parar e liberar todas as teclas

### ❌ Macro não detecta peixes

**Solução:**
- Verifique se está em 1920x1080
- Reconfigure as posições (Z, X, C)
- Teste manualmente puxando um peixe para confirmar as cores

### ❌ Pesca cancela aleatoriamente

**Solução:**
- Aumente o `DelayIscaVara` para 800-1000ms
- Diminua `DelayClique` para 10ms
- Verifique se a isca está sempre disponível

### ❌ Macro pesca muito rápido / muito lento

**Solução:**
- `DelayClique` controla velocidade de detecção
- Diminua para 5-10ms se quer mais rápido
- Aumente para 20-30ms se quer mais lento

## ⚠️ Avisos Importantes

- 🚨 **Use por sua conta e risco** - Macros podem violar ToS
- 🚨 **Monitore o macro** na primeira vez
- 🚨 **Configure corretamente as posições** ou pode não funcionar
- 🚨 **Nunca deixe desacompanhado** em áreas com NPCs agressivos
- 🚨 **Evite PvP** - Outros jogadores podem atacar enquanto AFK

## 📝 Notas

- **Isca é CRÍTICA**: Sem isca equipada, a pesca não funciona
- **Click M1 é automático**: O macro usa clique do mouse, não pressiona tecla
- **Coordenadas podem variar**: Cada monitor/resolução pode precisar recalibração
- **Failsafe recast**: Se passar de 30 ciclos sem detectar, recasta automaticamente

## 📊 Informações da Wiki

### Baits (Iscas) Testados
- **Chum**: Bait recomendado - Resultados equilibrados
- **Urchin**: Rápido - Bom para capturar pufferfish
- **Browncap**: Tempo médio - Bom para Red Snapper
- **Fish Meat**: Lento - Bom para tunas
- **Seaweed Bundle**: Tempo médio - Para mudskippers

### Locais Recomendados para Pesca
- **Etris Docks** (esquerda) - Bom para iniciantes
- **Vigils Docks** - Melhor loot
- **Isle of Vigils** - Diverso

### Atributos Levantados
- Strength (Força)
- Fortitude (Resistência)
- Intelligence (Inteligência)
- Willpower (Força de Vontade) - Muito XP
- Charisma (Carisma)

## 🔒 Licença

**PÚBLICO** - Livre para usar e compartilhar com a comunidade Deepwoken.

---

**Desenvolvido com ❤️ para Deepwoken**

*Última atualização: Julho 2025*
