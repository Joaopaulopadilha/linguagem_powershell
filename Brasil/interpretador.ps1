param($arquivo)

# Dicionário para armazenar variáveis
$variaveis = @{}

$linhas = Get-Content $arquivo

foreach($linha in $linhas) {
    $linha = $linha.Trim()
    
    # Pular linhas vazias e comentários
    if ($linha -eq "" -or $linha.StartsWith("#")) {
        continue
    }
    
    # Comando: escreva "texto"
    if ($linha -match '^escreva\s+"(.+)"$') {
        $texto = $matches[1]
        # Substituir variáveis no texto
        foreach($var in $variaveis.Keys) {
            $texto = $texto.Replace("{$var}", $variaveis[$var])
        }
        Write-Host $texto -ForegroundColor Green
    }
    
    # Comando: escreva variavel
    elseif ($linha -match '^escreva\s+([a-zA-Z_][a-zA-Z0-9_]*)$') {
        $nomeVar = $matches[1]
        if ($variaveis.ContainsKey($nomeVar)) {
            Write-Host $variaveis[$nomeVar] -ForegroundColor Green
        } else {
            Write-Host "Erro: Variável '$nomeVar' não foi definida" -ForegroundColor Red
        }
    }
    
    # Comando: var nome = "valor"
    elseif ($linha -match '^var\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*"(.+)"$') {
        $nomeVar = $matches[1]
        $valorVar = $matches[2]
        $variaveis[$nomeVar] = $valorVar
        Write-Host "Variável '$nomeVar' criada" -ForegroundColor Cyan
    }
    
    # Comando: var nome = numero
    elseif ($linha -match '^var\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*(\d+)$') {
        $nomeVar = $matches[1]
        $valorVar = [int]$matches[2]
        $variaveis[$nomeVar] = $valorVar
        Write-Host "Variável '$nomeVar' criada com valor $valorVar" -ForegroundColor Cyan
    }
    
    # Comando: pergunte "pergunta" para variavel
    elseif ($linha -match '^pergunte\s+"(.+)"\s+para\s+([a-zA-Z_][a-zA-Z0-9_]*)$') {
        $pergunta = $matches[1]
        $nomeVar = $matches[2]
        Write-Host $pergunta -ForegroundColor Yellow -NoNewline
        $resposta = Read-Host " "
        $variaveis[$nomeVar] = $resposta
        Write-Host "Resposta armazenada em '$nomeVar'" -ForegroundColor Cyan
    }
    
    # Comando: se variavel igual "valor" então
    elseif ($linha -match '^se\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+igual\s+"(.+)"\s+então$') {
        $nomeVar = $matches[1]
        $valor = $matches[2]
        
        if ($variaveis.ContainsKey($nomeVar) -and $variaveis[$nomeVar] -eq $valor) {
            Write-Host "Condição verdadeira para '$nomeVar'" -ForegroundColor Magenta
            # Aqui você poderia implementar um bloco de comandos
        } else {
            Write-Host "Condição falsa para '$nomeVar'" -ForegroundColor DarkYellow
        }
    }
    
    # Comando: espere numero (segundos)
    elseif ($linha -match '^espere\s+(\d+)$') {
        $segundos = [int]$matches[1]
        Write-Host "Aguardando $segundos segundo(s)..." -ForegroundColor Blue
        Start-Sleep -Seconds $segundos
    }
    
    # Comando: limpe
    elseif ($linha -match '^limpe$') {
        Clear-Host
        Write-Host "Tela limpa!" -ForegroundColor Blue
    }
    
    # Comando: repita numero vezes
    elseif ($linha -match '^repita\s+(\d+)\s+vezes\s+"(.+)"$') {
        $vezes = [int]$matches[1]
        $texto = $matches[2]
        
        # Substituir variáveis no texto
        foreach($var in $variaveis.Keys) {
            $texto = $texto.Replace("{$var}", $variaveis[$var])
        }
        
        Write-Host "Repetindo $vezes vezes:" -ForegroundColor Blue
        for ($i = 1; $i -le $vezes; $i++) {
            Write-Host "$i. $texto" -ForegroundColor Green
        }
    }
    
    # Comando: calcule variavel + numero
    elseif ($linha -match '^calcule\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\+\s*(\d+)$') {
        $nomeVar = $matches[1]
        $numero = [int]$matches[2]
        
        if ($variaveis.ContainsKey($nomeVar) -and $variaveis[$nomeVar] -is [int]) {
            $variaveis[$nomeVar] = $variaveis[$nomeVar] + $numero
            Write-Host "Nova valor de '$nomeVar': $($variaveis[$nomeVar])" -ForegroundColor Cyan
        } else {
            Write-Host "Erro: Variável '$nomeVar' não é um número" -ForegroundColor Red
        }
    }
    
    # Comando: liste_variaveis (para debug)
    elseif ($linha -match '^liste_variaveis$') {
        Write-Host "=== VARIÁVEIS ===" -ForegroundColor Magenta
        if ($variaveis.Count -eq 0) {
            Write-Host "Nenhuma variável definida" -ForegroundColor DarkGray
        } else {
            foreach($var in $variaveis.Keys) {
                Write-Host "$var = $($variaveis[$var])" -ForegroundColor White
            }
        }
        Write-Host "================" -ForegroundColor Magenta
    }
    
    # Comando não reconhecido
    else {
        Write-Host "Erro: Comando não reconhecido - $linha" -ForegroundColor Red
    }
}