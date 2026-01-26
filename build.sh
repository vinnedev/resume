#!/bin/bash

# Script para exportar main.tex para PDF
# Uso: ./export_pdf.sh
# Suporta: macOS, Linux e Windows (Git Bash/WSL)

# Diretório do script
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

# Nome do arquivo (sem extensão)
FILENAME="resume"

# ================= DETECÇÃO DE SO =================
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macos"
            ;;
        Linux*)
            # Verifica se é WSL (Windows Subsystem for Linux)
            if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
                OS="wsl"
            else
                OS="linux"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            OS="windows"
            ;;
        *)
            OS="unknown"
            ;;
    esac
    echo "$OS"
}

# ================= VERIFICAÇÃO DE LATEX =================
check_latex_installed() {
    if command -v pdflatex &> /dev/null; then
        LATEX_VERSION=$(pdflatex --version | head -n 1)
        echo "✅ LaTeX encontrado: $LATEX_VERSION"
        return 0
    else
        return 1
    fi
}

# ================= INSTRUÇÕES DE INSTALAÇÃO =================
show_install_instructions() {
    local os=$1
    echo "❌ Erro: pdflatex não está instalado."
    echo ""
    echo "📦 Instruções de instalação para seu sistema:"
    echo ""
    
    case "$os" in
        macos)
            echo "   🍎 macOS - Escolha uma opção:"
            echo ""
            echo "   Opção 1 - MacTeX (completo, ~4GB):"
            echo "      brew install --cask mactex"
            echo ""
            echo "   Opção 2 - BasicTeX (leve, ~100MB):"
            echo "      brew install --cask basictex"
            echo "      # Após instalar, adicione ao PATH:"
            echo "      export PATH=\"/Library/TeX/texbin:\$PATH\""
            echo ""
            echo "   Opção 3 - Download direto:"
            echo "      https://www.tug.org/mactex/"
            ;;
        linux)
            echo "   🐧 Linux - Escolha conforme sua distribuição:"
            echo ""
            echo "   Debian/Ubuntu:"
            echo "      sudo apt update"
            echo "      sudo apt install texlive-latex-base texlive-fonts-recommended texlive-latex-extra"
            echo ""
            echo "   Fedora/RHEL:"
            echo "      sudo dnf install texlive-scheme-basic texlive-latex"
            echo ""
            echo "   Arch Linux:"
            echo "      sudo pacman -S texlive-basic texlive-latex texlive-latexrecommended"
            echo ""
            echo "   openSUSE:"
            echo "      sudo zypper install texlive-latex"
            ;;
        wsl)
            echo "   🪟 WSL (Windows Subsystem for Linux):"
            echo ""
            echo "   Opção 1 - Instalar no WSL (recomendado):"
            echo "      sudo apt update"
            echo "      sudo apt install texlive-latex-base texlive-fonts-recommended texlive-latex-extra"
            echo ""
            echo "   Opção 2 - Usar MiKTeX do Windows:"
            echo "      Instale MiKTeX no Windows e adicione ao PATH do WSL"
            ;;
        windows)
            echo "   🪟 Windows - Escolha uma opção:"
            echo ""
            echo "   Opção 1 - MiKTeX (recomendado):"
            echo "      Download: https://miktex.org/download"
            echo "      Após instalar, reinicie o terminal."
            echo ""
            echo "   Opção 2 - TeX Live:"
            echo "      Download: https://www.tug.org/texlive/acquire-netinstall.html"
            echo ""
            echo "   Opção 3 - Via Chocolatey:"
            echo "      choco install miktex"
            ;;
        *)
            echo "   Sistema não reconhecido."
            echo "   Visite: https://www.latex-project.org/get/"
            ;;
    esac
    echo ""
}

# ================= ABRIR PDF =================
open_pdf() {
    local os=$1
    local file=$2
    
    case "$os" in
        macos)
            open "$file"
            ;;
        linux)
            if command -v xdg-open &> /dev/null; then
                xdg-open "$file" 2>/dev/null &
            elif command -v evince &> /dev/null; then
                evince "$file" 2>/dev/null &
            elif command -v okular &> /dev/null; then
                okular "$file" 2>/dev/null &
            else
                echo "ℹ️  Abra manualmente: $file"
            fi
            ;;
        wsl)
            # Abre com o programa padrão do Windows
            if command -v wslview &> /dev/null; then
                wslview "$file"
            elif command -v explorer.exe &> /dev/null; then
                explorer.exe "$(wslpath -w "$file")"
            else
                echo "ℹ️  Abra manualmente: $file"
            fi
            ;;
        windows)
            start "" "$file" 2>/dev/null || cmd //c start "" "$file"
            ;;
        *)
            echo "ℹ️  Abra manualmente: $file"
            ;;
    esac
}

# ================= MAIN =================
echo "🔍 Detectando sistema operacional..."
OS=$(detect_os)

case "$OS" in
    macos)  echo "🍎 Sistema detectado: macOS" ;;
    linux)  echo "🐧 Sistema detectado: Linux" ;;
    wsl)    echo "🪟 Sistema detectado: WSL (Windows Subsystem for Linux)" ;;
    windows) echo "🪟 Sistema detectado: Windows" ;;
    *)      echo "❓ Sistema detectado: Desconhecido" ;;
esac

echo ""
echo "🔍 Verificando instalação do LaTeX..."

if ! check_latex_installed; then
    show_install_instructions "$OS"
    exit 1
fi

# Cria pasta output se não existir
OUTPUT_DIR="$DIR/output"
mkdir -p "$OUTPUT_DIR"

# ================= COMPILAR VERSÃO EM INGLÊS =================
echo ""
echo "📄 Compilando main.tex (Inglês)..."

pdflatex -interaction=nonstopmode "main.tex" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    mv "resume.pdf" "$OUTPUT_DIR/Vinicius Abreu_en_US.pdf"
    echo "✅ Gerado: output/Vinicius Abreu_en_US.pdf"
    rm -f resume.aux resume.log resume.out 2>/dev/null
else
    echo "❌ Erro ao compilar main.tex"
    echo "📋 Verifique o arquivo resume.log para mais detalhes."
fi

# ================= COMPILAR VERSÃO EM PORTUGUÊS =================
echo ""
echo "📄 Compilando main-pt_BR.tex (Português)..."

if [ -f "main-pt_BR.tex" ]; then
    pdflatex -interaction=nonstopmode "main-pt_BR.tex" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        mv "resume-pt_BR.pdf" "$OUTPUT_DIR/Vinicius Abreu.pdf"
        echo "✅ Gerado: output/Vinicius Abreu.pdf"
        rm -f resume-pt_BR.aux resume-pt_BR.log resume-pt_BR.out 2>/dev/null
    else
        echo "❌ Erro ao compilar main-pt_BR.tex"
        echo "📋 Verifique o arquivo resume-pt_BR.log para mais detalhes."
    fi
else
    echo "⚠️  Arquivo main-pt_BR.tex não encontrado, pulando..."
fi

# ================= FINALIZAÇÃO =================
echo ""
echo "🧹 Arquivos auxiliares removidos."
echo ""
echo "📂 PDFs gerados na pasta output/:"
ls -la "$OUTPUT_DIR"/*.pdf 2>/dev/null

# Abre a pasta output
echo ""
echo "📂 Abrindo pasta output..."
open_pdf "$OS" "$OUTPUT_DIR"
