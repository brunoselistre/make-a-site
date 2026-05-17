# Pipeline de Deploy de Sites

Automatize o deploy de sites HTML/CSS/JS estáticos em qualquer hospedagem. Substitui uploads manuais por um pipeline automatizado e repetível: edite os arquivos em `src/` → execute um comando → site no ar.

**Em outras palavras:** você edita o código, executa um comando, e o site está no ar — validado, com backup e enviado automaticamente. Se algo quebrar, um único comando reverte tudo.

---

## 🤖 Uso com Ferramentas de IA

Este projeto inclui instruções para agentes de IA em [`AGENTS.md`](./AGENTS.md). Qualquer assistente de IA (Claude, Cursor, Copilot, etc.) pode ler esse arquivo e entender como trabalhar com este pipeline.

### O que a IA pode fazer por você

| Tarefa | Descrição |
|--------|-----------|
| **Criar novo site** | Guia em 5 fases: coleta de informações → escolha de template → personalização de cores/fontes → build → preview |
| **Editar site existente** | Alterar cores, textos, adicionar/remover páginas, ajustar layout |
| **Deploy** | Executar preflight, deploy e verificação pós-deploy |
| **Debug** | Diagnosticar erros de conexão, credenciais ou smoke test |

### Como usar

Simplesmente aponte seu assistente de IA para o arquivo `AGENTS.md` e descreva o que você precisa:

> *"Crie um novo site para uma clínica odontológica usando o template clássico"*
>
> *"Mude a cor primária para azul marinho e a fonte para uma serifada elegante"*
>
> *"Adicione uma página de blog e remova a página de serviços"*

A IA seguirá automaticamente as regras do projeto, incluindo:
- Editar apenas arquivos em `src/`
- Seguir constraints específicas de cada template
- Substituir placeholders corretamente
- Verificar checklist de segurança antes do deploy

---

## Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Provedores](#provedores)
3. [Estrutura do repositório](#estrutura-do-repositório)
4. [Templates de estilo visual](#templates-de-estilo-visual)
5. [Configuração inicial](#configuração-inicial)
6. [Fluxo de desenvolvimento diário](#fluxo-de-desenvolvimento-diário)
7. [Fazendo deploy para produção](#fazendo-deploy-para-produção)
8. [Revertendo o deploy](#revertendo-o-deploy)
9. [Deploy automático com GitHub Actions](#deploy-automático-com-github-actions)
10. [Solução de problemas](#solução-de-problemas)

---

## Pré-requisitos

Você precisa configurar algumas coisas no seu computador e na sua hospedagem antes de fazer o primeiro deploy. Faça isso uma vez por máquina — não por projeto.

### 1. Instalar o Git

O Git rastreia as alterações no código e é necessário para clonar este repositório.

**Mac:**
1. Abra o Terminal (pressione `Cmd + Espaço`, digite "Terminal" e pressione Enter)
2. Execute: `git --version`
3. Se não estiver instalado, o macOS vai oferecer instalar as Ferramentas de Linha de Comando do Xcode — clique em Instalar e aguarde

**Windows:**
1. Baixe o instalador em https://git-scm.com/download/win
2. Execute o instalador — as opções padrão funcionam bem
3. Abra o "Git Bash" pelo menu Iniciar (use-o no lugar do Prompt de Comando para todos os comandos deste guia)

**Verifique se funcionou:**
```bash
git --version
# Saída esperada: git version 2.x.x
```

---

### 2. Instalar o lftp

O `lftp` é a ferramenta que faz o upload dos arquivos para o servidor via FTP e SFTP. Ele suporta upload incremental, remoção de arquivos obsoletos e reconexão automática. Necessário apenas se você usar os provedores `ftp` ou `sftp`.

**Mac:**
```bash
brew install lftp
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install -y lftp
```

**Windows (Git Bash):**
Instale o WSL (Windows Subsystem for Linux) e execute o comando Linux acima dentro dele. Alternativamente, use o FileZilla para uploads manuais quando necessário.

**Verifique se funcionou:**
```bash
lftp --version
# Saída esperada: LFTP | Version 4.x.x
```

---

### 3. Obter as credenciais do seu provedor de hospedagem

O pipeline suporta 7 provedores de deploy. As credenciais necessárias variam por provedor — veja a seção [Provedores](#provedores) abaixo para detalhes de cada um.

Para **FTP** (o padrão), você precisará de:
- **Hostname FTP** (ex: `files.hostinger.com` ou IP)
- **Usuário** (ex: `u123456789`)
- **Senha** (definida por você ao criar a conta FTP)
- **Porta**: `21`

> **Atenção:** A senha FTP é separada da senha da sua conta de hospedagem. Se não lembrar, redefina-a no painel do seu provedor.

---

## Provedores

O pipeline de deploy é modular. Um único comando (`bash scripts/deploy.sh production`) funciona com qualquer um dos 7 provedores abaixo. O provedor ativo é definido pela variável `DEPLOY_PROVIDER` em `config/.env.production`.

| Provedor | `DEPLOY_PROVIDER` | Quando usar |
|---|---|---|
| **FTP** | `ftp` | Hospedagem compartilhada (Hostinger, Locaweb, etc.) |
| **SFTP** | `sftp` | Servidor VPS, AWS EC2, DigitalOcean — qualquer servidor com SSH |
| **S3** | `s3` | AWS S3, Cloudflare R2, MinIO — storage de objetos |
| **Vercel** | `vercel` | Projetos Next.js ou sites estáticos na Vercel |
| **Netlify** | `netlify` | Sites estáticos na Netlify |
| **Local** | `local` | Copia os arquivos para uma pasta local (testes, NAS, pen drive) |
| **Rsync** | `rsync` | Qualquer servidor com SSH — mais rápido que SFTP para grandes sites |

> **Mudar de provedor:** edite `DEPLOY_PROVIDER` em `config/.env.production` e adicione as variáveis do novo provedor. Não é necessário reinstalar nada.

### Quick start por provedor

#### FTP (padrão)

```bash
# config/.env.production
DEPLOY_PROVIDER=ftp
SITE_URL=https://dominiodocliente.com.br
FTP_HOST=files.hostinger.com
FTP_USER=u123456789
FTP_PASSWORD=sua-senha-ftp
FTP_PORT=21
REMOTE_PATH=/home/u123456789/public_html
```

**Pré-requisito:** `lftp` instalado (veja [Pré-requisitos](#pré-requisitos)).

#### SFTP

```bash
# config/.env.production
DEPLOY_PROVIDER=sftp
SITE_URL=https://dominiodocliente.com.br
SFTP_HOST=seu-servidor.com
SFTP_USER=root
SFTP_PASSWORD=sua-senha-ssh
SFTP_PORT=22
REMOTE_PATH=/var/www/html
```

**Pré-requisito:** `lftp` instalado (o mesmo do FTP).

#### S3

```bash
# config/.env.production
DEPLOY_PROVIDER=s3
SITE_URL=https://dominiodocliente.com.br
S3_BUCKET=meu-bucket
S3_REGION=us-east-1
S3_ACCESS_KEY=AKIA...
S3_SECRET_KEY=...
S3_ENDPOINT=          # opcional — para MinIO, Cloudflare R2, etc.
```

**Pré-requisito:** AWS CLI instalado (`aws --version`).

#### Vercel

```bash
# config/.env.production
DEPLOY_PROVIDER=vercel
SITE_URL=https://dominiodocliente.vercel.app
VERCEL_TOKEN=seu-token
VERCEL_PROJECT_ID=prj_...
VERCEL_ORG_ID=team_...   # ou seu user ID
```

**Pré-requisito:** Vercel CLI instalado (`npm i -g vercel`).

#### Netlify

```bash
# config/.env.production
DEPLOY_PROVIDER=netlify
SITE_URL=https://dominiodocliente.netlify.app
NETLIFY_AUTH_TOKEN=seu-token
NETLIFY_SITE_ID=seu-site-id
```

**Pré-requisito:** Netlify CLI instalado (`npm i -g netlify-cli`).

#### Local

```bash
# config/.env.production
DEPLOY_PROVIDER=local
SITE_URL=file:///caminho/para/o/site
LOCAL_DEST=/caminho/para/o/site
```

**Pré-requisito:** nenhum — apenas um caminho de destino válido.

#### Rsync

```bash
# config/.env.production
DEPLOY_PROVIDER=rsync
SITE_URL=https://dominiodocliente.com.br
RSYNC_HOST=seu-servidor.com
RSYNC_USER=root
RSYNC_PORT=22
REMOTE_PATH=/var/www/html
```

**Pré-requisito:** `rsync` e `ssh` instalados (padrão em Mac/Linux).

---

## Estrutura do repositório

```
projeto-cliente/
├── src/                      # SEU CÓDIGO-FONTE — edite os arquivos aqui
│   ├── index.html            # Página inicial
│   ├── about.html            # Página Sobre
│   ├── services.html         # Página Serviços
│   ├── contact.html          # Página Contato
│   ├── css/
│   │   ├── main.css          # Estilos globais
│   │   └── components/       # Um arquivo CSS por componente
│   ├── js/
│   │   ├── main.js           # JavaScript (ícones sociais, WhatsApp, ano no footer)
│   │   └── modules/          # Módulos JS individuais
│   ├── images/               # Imagens
│   └── fonts/                # Fontes web personalizadas
├── backups/                  # GERADO AUTOMATICAMENTE — cópias locais de cada deploy
├── config/
│   ├── .env.example          # Template com as variáveis necessárias — pode ser commitado
│   └── .env.production       # Credenciais reais do servidor — nunca commite este arquivo
├── scripts/
│   ├── setup.sh              # Configuração inicial — cria o arquivo de ambiente
│   ├── preflight.sh          # Valida tudo antes de fazer o deploy
│   ├── deploy.sh             # O script principal de deploy
│   └── rollback.sh           # Restaura uma versão anterior do site
├── .github/
│   └── workflows/
│       └── deploy.yml        # Diz ao GitHub para fazer deploy automático ao enviar para main
└── .gitignore                # Arquivos que o Git nunca deve rastrear (backups/, credenciais, etc.)
```

**A regra mais importante:** edite apenas arquivos dentro de `src/`. Os arquivos em `src/` são enviados diretamente ao servidor — sem etapa de build.

---

## Templates de estilo visual

O gerador suporta 5 estilos visuais distintos. Ao usar o comando `/new-website`, o agente pergunta qual template você prefere na **Fase 2** e aplica automaticamente o HTML e CSS corretos.

| # | Nome | TEMPLATE_ID | Fontes padrão | Ideal para |
|---|---|---|---|---|
| 1 | **Minimalista** | `minimalist` | Inter | Marcas de luxo, portfólios, estética |
| 2 | **Moderno / SaaS** | `modern` | Syne + DM Sans | Software, apps, startups de tecnologia |
| 3 | **Bold / Brutalista** | `bold` | Bebas Neue + Space Grotesk | Agências criativas, streetwear, música |
| 4 | **Clássico / Corporativo** | `classic` | IBM Plex Serif + IBM Plex Sans | Advocacia, finanças, saúde, B2B |
| 5 | **Retrô / Nostálgico** | `retro` | Playfair Display + Lora | Cafeterias, marcas artesanais, indie |

### Diferenças estruturais por template

- **Minimalista**: hero split-screen (texto à esquerda, foto à direita) — sem overlay escuro
- **Moderno**: hero com gradientes CSS (sem imagem), seção bento grid na homepage
- **Bold**: hero text-only sem imagem de fundo, tipografia oversized (pode ultrapassar a viewport intencionalmente), `.page-hero` alinhado à esquerda
- **Clássico**: layout tradicional com hero de foto + overlay
- **Retrô**: mesma estrutura do Clássico; o efeito de textura de papel é 100% CSS

### Arquivos dos templates

```
templates/
  minimalist/   css/main.css + 4 páginas HTML
  modern/       css/main.css + 4 páginas HTML
  bold/         css/main.css + 4 páginas HTML
  classic/      css/main.css + 4 páginas HTML
  retro/        css/main.css + 4 páginas HTML
```

Ao gerar um novo projeto, o `/new-website` copia o template escolhido para `src/` via rsync — os arquivos em `src/js/`, `src/fonts/` e `src/images/` são compartilhados por todos os templates.

---

## Configuração inicial

Faça isso uma vez ao iniciar um novo projeto de cliente.

### Passo 1 — Abrir um terminal na pasta do projeto

**Mac:** Clique com o botão direito na pasta do projeto no Finder → "Novo Terminal na Pasta"

**Windows:** Abra o Git Bash e navegue até a pasta:
```bash
cd /c/Users/SeuNome/Projects/projeto-cliente
```

### Passo 2 — Configurar as variáveis de ambiente

Execute o script de configuração — ele fará as perguntas e criará o arquivo automaticamente:

```bash
bash scripts/setup.sh
```

Você verá um bloco de perguntas. O primeiro passo é escolher o provedor de deploy:

```
── Provedor de deploy ─
Provedor (ftp, sftp, s3, vercel, netlify, local, rsync) [ftp]: ftp
```

Depois, o script pergunta as credenciais específicas do provedor escolhido. Para FTP, por exemplo:

```
── Credenciais FTP (config/.env.production) ─
Hostname FTP (ex: files.hostinger.com): files.hostinger.com
Usuário FTP (ex: u123456789): u123456789
Senha FTP: ••••••••
Porta FTP [21]:
Caminho remoto (ex: /home/u123456789/public_html): /home/u123456789/public_html
URL do site (ex: https://dominiodocliente.com.br): https://dominiodocliente.com.br
```

O script cria `config/.env.production` com suas credenciais. Esse arquivo está no `.gitignore` e nunca será commitado. Se precisar alterar um valor depois, execute `bash scripts/setup.sh` novamente — ele pergunta antes de sobrescrever. Para mudar de provedor, basta escolher outro na primeira pergunta.

> **Número do WhatsApp:** o botão flutuante do WhatsApp é configurado diretamente no HTML — edite `<meta name="whatsapp-number" content="5511999999999">` em cada página de `src/`.

### Passo 3 — Verificar se tudo está conectado

Execute isso para confirmar que a conexão com o provedor, o arquivo de ambiente e a estrutura de arquivos estão corretos:

```bash
bash scripts/preflight.sh
```

Saída esperada (exemplo com FTP):
```
Executando verificações pré-deploy...
Testando conectividade FTP com files.hostinger.com:21...
Conectividade FTP OK.
Verificações concluídas.
```

Se aparecer um erro, leia a mensagem — ela indicará exatamente o que está faltando.

---

## Fluxo de desenvolvimento diário

### Visualizar o site localmente

Não há build step — abra os arquivos diretamente com qualquer servidor HTTP estático:

No VS Code, a extensão live server pode ser utilizada.

```bash
# Python (disponível em qualquer Mac/Linux):
cd src && python3 -m http.server 8080
```

Abra `http://localhost:8080` no navegador. Edite os arquivos em `src/` e recarregue o navegador para ver as alterações.

Alternativas:
- **VS Code:** instale a extensão "Live Server" e clique em "Go Live"
- **WebStorm / PhpStorm:** clique no ícone do navegador na barra de ferramentas ao abrir um `.html`

---

## Fazendo deploy para produção

Quando estiver pronto para enviar as alterações para o site no ar, execute:

```bash
bash scripts/deploy.sh production
```

### O que acontece passo a passo

1. **Preflight** — o script verifica que todas as credenciais do provedor ativo estão definidas e que a conexão funciona; se algo estiver errado, para aqui antes de tocar no servidor
2. **Backup local** — uma cópia de `src/` é salva em `backups/src-TIMESTAMP/` no seu computador; se o deploy der errado, você pode reverter re-enviando esse backup
3. **Upload** — o script envia todos os arquivos de `src/` para o destino configurado (FTP, SFTP, S3, Vercel, Netlify, local ou rsync); arquivos removidos de `src/` também são removidos do destino
4. **Teste de fumaça** — o script acessa sua URL e verifica se recebe HTTP 200; se receber outra resposta, exibe o comando exato de rollback e encerra com erro
5. **Resumo** — exibe a confirmação com timestamp, localização do backup local e URL do site

> **Atenção:** em provedores sem acesso SSH (plano Single de hospedagem compartilhada), não há reversão automática no servidor. Se o teste de fumaça falhar, o script exibirá o comando de rollback exato para você executar.

### Exemplo de saída de um deploy bem-sucedido

```
==> Executando verificações pré-deploy...
Testando conectividade FTP com files.hostinger.com:21...
Conectividade FTP OK.
Verificações concluídas.
==> Criando backup local em backups/src-20250418-143022...
==> Enviando src/ para files.hostinger.com:/home/u123456789/public_html...
Mirror: 12 files transferred, 0 errors
==> Executando teste de fumaça em https://dominiodocliente.com.br...
================================================
  Deploy concluído
  Ambiente    : production
  Timestamp   : 20250418-143022
  Backup local : backups/src-20250418-143022
  Site        : https://dominiodocliente.com.br (HTTP 200)
================================================
```

---

## Revertendo o deploy

Se você fez um deploy e algo está errado no site no ar, você pode restaurar a versão anterior re-enviando um backup local via o mesmo provedor de deploy.

> **Importante:** backups ficam armazenados em `backups/` no seu computador. Se você perder o computador ou deletar essa pasta, os backups são perdidos. Mantenha pelo menos os últimos deploys.

### Reverter para o backup mais recente

```bash
bash scripts/rollback.sh production
```

O script exibirá a lista de backups disponíveis com seus timestamps e pedirá confirmação:

```
Backups disponíveis (mais recente primeiro):
src-20250418-143022
src-20250417-091500
src-20250415-184301

==> Padrão: backup mais recente: src-20250418-143022
Confirmar? [s/N]
```

Digite `s` e pressione Enter. Os arquivos do backup serão enviados para o servidor em segundos.

### Reverter para um backup específico

Se o backup mais recente também estiver com problema, você pode buscar um mais antigo passando uma data:

```bash
bash scripts/rollback.sh production 20250415
```

O script encontra o primeiro backup cujo nome contém `20250415` e o restaura diretamente, sem pedir confirmação.

### Ver os backups disponíveis localmente

```bash
ls -lht backups/
```

Backups não são deletados automaticamente. Após confirmar que um deploy está estável, limpe os backups antigos para economizar espaço em disco:

```bash
# Deletar um backup específico
rm -rf backups/src-20250415-184301

# Deletar todos os backups com mais de 30 dias
find backups/ -maxdepth 1 -mtime +30 -exec rm -rf {} +
```

---

## Deploy automático com GitHub Actions

Uma vez configurado, você não precisa mais executar `deploy.sh` manualmente. Cada vez que você enviar código para o branch `main` no GitHub, o deploy roda automaticamente na nuvem.

### Como funciona

O GitHub executa uma máquina Ubuntu virtual, faz o checkout do seu código e envia os arquivos de `src/` para o destino configurado. O workflow lê `DEPLOY_PROVIDER` e as credenciais correspondentes dos Secrets do repositório. Na primeira execução ele envia todos os arquivos; nas seguintes, só envia o que mudou. As credenciais ficam armazenadas como Secrets criptografados do GitHub.

### Passo 1 — Enviar o repositório para o GitHub

Se ainda não fez isso:

1. Acesse https://github.com e clique em **New repository**
2. Nomeie-o (ex: `projeto-cliente`), defina como **Privado** e clique em **Create repository**
3. De volta ao terminal, execute:

```bash
git init
git add .
git commit -m "Commit inicial"
git branch -M main
git remote add origin https://github.com/seu-usuario/projeto-cliente.git
git push -u origin main
```

### Passo 2 — Adicionar os secrets do repositório

Os Secrets do GitHub armazenam suas credenciais do servidor de forma criptografada. O workflow de deploy os lê em tempo de execução.

1. No GitHub, acesse a página do seu repositório
2. Clique em **Settings** (barra de navegação superior)
3. Na barra lateral esquerda, clique em **Secrets and variables** → **Actions**
4. Clique em **New repository secret**
5. Adicione cada um dos seguintes secrets, um por vez:

| Nome do secret | Onde encontrar o valor |
|---|---|
| `DEPLOY_PROVIDER` | Provedor ativo: `ftp`, `sftp`, `s3`, `vercel`, `netlify`, `local`, `rsync` |
| `SITE_URL` | URL do site (ex: `https://dominiodocliente.com.br`) |

**Se `DEPLOY_PROVIDER=ftp`:**
| `FTP_HOST` | Hostname FTP (ex: `files.hostinger.com`) |
| `FTP_USER` | Usuário FTP (ex: `u123456789`) |
| `FTP_PASSWORD` | Senha da conta FTP |
| `FTP_PORT` | `21` |
| `REMOTE_PATH` | `/home/u123456789/public_html` |

**Se `DEPLOY_PROVIDER=sftp`:**
| `SFTP_HOST` | Hostname do servidor |
| `SFTP_USER` | Usuário SSH |
| `SFTP_PASSWORD` | Senha SSH |
| `SFTP_PORT` | `22` |
| `REMOTE_PATH` | `/var/www/html` |

**Se `DEPLOY_PROVIDER=s3`:**
| `S3_BUCKET` | Nome do bucket |
| `S3_REGION` | Região (ex: `us-east-1`) |
| `S3_ACCESS_KEY` | AWS Access Key ID |
| `S3_SECRET_KEY` | AWS Secret Access Key |
| `S3_ENDPOINT` | Endpoint customizado (opcional — MinIO, R2, etc.) |

**Se `DEPLOY_PROVIDER=vercel`:**
| `VERCEL_TOKEN` | Token da Vercel |
| `VERCEL_PROJECT_ID` | ID do projeto |
| `VERCEL_ORG_ID` | ID da organização ou usuário |

**Se `DEPLOY_PROVIDER=netlify`:**
| `NETLIFY_AUTH_TOKEN` | Token pessoal do Netlify |
| `NETLIFY_SITE_ID` | ID do site |

**Se `DEPLOY_PROVIDER=local`:**
| `LOCAL_DEST` | Caminho local de destino |

**Se `DEPLOY_PROVIDER=rsync`:**
| `RSYNC_HOST` | Hostname do servidor |
| `RSYNC_USER` | Usuário SSH |
| `RSYNC_PORT` | `22` |
| `REMOTE_PATH` | `/var/www/html` |

Para adicionar cada secret: digite o nome no campo **Name**, cole o valor no campo **Secret**, clique em **Add secret**.

### Passo 3 — Testar

Faça qualquer pequena alteração em um arquivo de `src/`, faça o commit e envie:

```bash
git add .
git commit -m "Testar deploy automático"
git push
```

### Passo 4 — Acompanhar o deploy

1. No GitHub, clique na aba **Actions** no topo do repositório
2. Você verá um workflow chamado **Deploy** com um círculo amarelo girando (em andamento) ou um check verde (concluído)
3. Clique no workflow para ver o log completo, incluindo cada etapa e sua saída

Se o workflow exibir um X vermelho, clique nele, depois clique no job **deploy** para ver qual etapa falhou e ler a mensagem de erro.

---

## Solução de problemas

### Erro de autenticação (Login incorrect / 530)

1. Confirme a senha no painel do seu provedor de hospedagem — a senha de deploy é separada da senha da conta principal. Redefina-a se necessário.
2. Verifique se o usuário está no formato correto (ex: `u123456789` para FTP, não apenas o nome de usuário).
3. Confirme que o hostname é o exato listado no painel do provedor (varia por servidor).
4. Verifique se `DEPLOY_PROVIDER` em `config/.env.production` corresponde ao provedor que você configurou.

---

### Timeout de conexão durante o deploy

Em hospedagem compartilhada, picos de tráfego podem causar timeouts. O script já tenta reconectar até 3 vezes automaticamente. Se persistir:

1. Verifique se o firewall local não está bloqueando a porta necessária (21 para FTP, 22 para SFTP/RSYNC).
2. Tente executar novamente — timeouts transitórios são comuns em hospedagem compartilhada.
3. Se o problema persistir, entre em contato com o suporte do seu provedor de hospedagem.

---

### Teste de fumaça retorna status diferente de 200, mas o site parece normal no navegador

Navegadores seguem redirecionamentos automaticamente; o curl não. Muitos provedores redirecionam HTTP para HTTPS, ou `www.` para o domínio sem prefixo (ou vice-versa).

Encontre a URL que retorna exatamente 200:
```bash
curl -IL http://dominiodocliente.com.br
curl -IL https://dominiodocliente.com.br
curl -IL https://www.dominiodocliente.com.br
```

Procure a linha `HTTP/2 200` (ou `HTTP/1.1 200 OK`). Atualize o `SITE_URL` no seu arquivo de ambiente para corresponder à URL que retornou 200.

---

### Deploy pelo GitHub Actions falha

**Causas mais comuns:**

1. **Senha incorreta** — vá em GitHub → Settings → Secrets → Actions → clique no secret de senha do provedor ativo (ex: `FTP_PASSWORD`, `SFTP_PASSWORD`, `S3_SECRET_KEY`) → Update secret → cole a senha correta → Save.
2. **Secret ausente ou com typo** — confirme que todos os secrets do provedor ativo foram adicionados e que os nomes estão exatos (diferenciam maiúsculas de minúsculas). Veja a tabela na seção [Deploy automático com GitHub Actions](#deploy-automático-com-github-actions).
3. **Provedor não configurado** — confirme que `DEPLOY_PROVIDER` está definido como secret e corresponde ao provedor que você configurou.
4. **Hostname errado** — abra a aba Actions → clique no workflow com falha → expanda a etapa de deploy para ler o erro exato.
