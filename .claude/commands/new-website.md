# Agente de Novo Projeto

Você está configurando um novo projeto de site para um cliente a partir do template em `website-gen-php/`. Siga as fases em ordem. Nunca pule uma fase. Aguarde a resposta do usuário antes de avançar.

---

## Fase 1 — Informações do cliente

Pergunte um item por vez:

1. **Nome da empresa** — usado nos títulos, package.json e nome da pasta.
2. **Segmento / finalidade** — ex: clínica odontológica, restaurante, escritório de advocacia, academia. Define as imagens e textos de placeholder.
3. **URL do site** — ex: `https://dominiodocliente.com.br`. Usada no teste de fumaça.
4. **Hostname FTP** — ex: `files.hostinger.com` (veja hPanel > Arquivos > Contas FTP)
5. **Usuário FTP** — ex: `u123456789`
6. **Senha FTP** — senha da conta FTP (separada da senha da Hostinger)
7. **Caminho remoto** — ex: `/home/u123456789/public_html`
8. **Número do WhatsApp** — ex: `5511999999999` (DDI + DDD + número, sem espaços ou símbolos). Aparecerá como botão flutuante em todas as páginas.
9. **Páginas** — padrão: `index, sobre, serviços, contato`. Enter para aceitar ou liste as desejadas.
10. **Repositório GitHub** — ex: `acme-website`. Deixe em branco para pular.

---

## Fase 2 — Escolha do template

Diga: *"Agora vamos escolher o estilo visual. Qual template combina mais com a marca?"*

Apresente esta lista em uma única mensagem:

```
1. Minimalista       — Espaço em branco, paleta limitada, hero split-screen.
                       Ideal para: marcas de luxo, portfólios, estética.

2. Moderno / SaaS    — Glassmorfismo, bento grid, fundo escuro, estilo app.
                       Ideal para: software, apps, startups de tecnologia.

3. Bold / Brutalista — Tipografia gigante, alto contraste, hero sem imagem.
                       Ideal para: agências criativas, streetwear, marcas ousadas.

4. Clássico / Corp.  — Layout estruturado, serifa nos títulos, hero com foto.
                       Ideal para: advocacia, finanças, saúde, B2B.

5. Retrô / Nostálgico — Textura de papel (CSS), tons terrosos, fontes serifadas.
                       Ideal para: cafeterias, marcas artesanais, indie brands.

Digite o número (1–5) ou o nome do template.
```

Registre o template escolhido como `TEMPLATE_ID`:

| Escolha | TEMPLATE_ID |
|---|---|
| 1 / Minimalista | `minimalist` |
| 2 / Moderno | `modern` |
| 3 / Bold | `bold` |
| 4 / Clássico | `classic` |
| 5 / Retrô | `retro` |

---

Após confirmar o template, diga: *"Ótimo! Agora vamos personalizar as cores e fontes."*

Envie as perguntas abaixo em uma única mensagem. Omita as marcadas como **[omitir]** para o template escolhido:

1. **Cor primária** — cor principal da marca (hex ou descrição: "verde esmeralda escuro")
   - **[omitir para Bold]** — sempre começa em preto puro
2. **Cor secundária** — cor de destaque e CTAs
3. **Cor de fundo** — padrão varia por template
   - **[omitir para Modern]** — sempre fundo escuro
   - **[omitir para Bold]** — sempre `#f5f0e8`
4. **Cor do texto** — padrão: cinza escuro
5. **Estilo de fonte** — ex: "limpo e moderno", "serifado elegante", "geométrico e ousado"
   - **[omitir para Bold e Retrô]** — fontes definidas pelo template
6. **Direção visual** — ex: minimalista, corporativo, luxuoso, descontraído, técnico
7. **Sites de referência** — URLs ou descrições (opcional)
8. **Outras observações** — logo, tom de voz, coisas a evitar

---

## Fase 3 — Interpretar e confirmar

Converta as respostas em tokens concretos:

**Cores:** transforme descrições em hex coerente com o segmento e direção visual.

**Par de fontes padrão por template** (use como ponto de partida; substitua se o cliente pediu algo diferente):

| TEMPLATE_ID | Títulos | Corpo | URL Google Fonts |
|---|---|---|---|
| `minimalist` | Inter 700 | Inter 400 | `family=Inter:wght@300;400;500;700` |
| `modern` | Syne 700/800 | DM Sans 400 | `family=Syne:wght@400;700;800&family=DM+Sans:wght@400;500` |
| `bold` | Bebas Neue | Space Grotesk 400 | `family=Bebas+Neue&family=Space+Grotesk:wght@400;500;700` |
| `classic` | IBM Plex Serif 700 | IBM Plex Sans 400 | `family=IBM+Plex+Serif:wght@400;700&family=IBM+Plex+Sans:wght@400;600` |
| `retro` | Playfair Display 700 | Lora 400 | `family=Playfair+Display:wght@400;700&family=Lora:ital,wght@0,400;0,600;1,400` |

**Par de fontes (por estilo declarado pelo cliente):**
| Estilo | Títulos | Corpo |
|---|---|---|
| Minimalista/moderno | Inter 700 | Inter 400 |
| Serifado elegante | Playfair Display | Source Serif 4 |
| Geométrico/ousado | Syne | DM Sans |
| Amigável/arredondado | Nunito | Nunito |
| Corporativo | IBM Plex Sans | IBM Plex Sans |
| Luxuoso | Cormorant Garamond | Jost |
| Técnico | Space Grotesk | IBM Plex Mono |

**Keyword de imagem** — derive uma palavra-chave em inglês do segmento para `loremflickr.com`:
- Clínica odontológica → `dental`
- Restaurante → `restaurant,food`
- Escritório de advocacia → `law,office`
- Academia → `fitness,gym`
- Agência → `office,business`
- Moda → `fashion,clothing`
- Estética/spa → `beauty,spa`
- Construtora → `construction,architecture`

**Border radius:** 4px (corporativo/técnico) · 8px (moderno) · 14px (amigável/descontraído)

Apresente o resumo e aguarde confirmação:

```
Aqui está o que vou aplicar:

Primária:    #1a3a5c
Secundária:  #e8a020
Fundo:       #f9f9f9
Texto:       #2d2d2d
Títulos:     Playfair Display
Corpo:       Source Serif 4
Radius:      6px
Imagens:     loremflickr.com → "law,office"

Podemos continuar? (sim / ajustar algo)
```

---

## Fase 4 — Montar o projeto

Execute cada passo imprimindo uma linha de status antes.

### 4.1 — Copiar o template

Use o `TEMPLATE_ID` registrado na Fase 2. Execute os dois passos em sequência:

**Passo A — Copiar infraestrutura base** (scripts, config, js, imagens — sem HTML/CSS do template padrão):
```bash
rsync -a \
  --exclude='.git/' \
  --exclude='backups/' \
  --exclude='config/.env.production' \
  --exclude='templates/' \
  --exclude='src/css/' \
  --exclude='src/index.html' \
  --exclude='src/about.html' \
  --exclude='src/services.html' \
  --exclude='src/contact.html' \
  ./ ../SLUG/
```

**Passo B — Sobrescrever com o template escolhido** (HTML + CSS):
```bash
rsync -a templates/TEMPLATE_ID/ ../SLUG/src/
```

Substitua `TEMPLATE_ID` pelo valor registrado na Fase 2 (`minimalist`, `modern`, `bold`, `classic` ou `retro`).

### 4.2 — Criar arquivo de ambiente

**`config/.env.production`** — credenciais lidas pelos scripts de deploy via shell:
```
FTP_HOST=<valor>
FTP_USER=<valor>
FTP_PASSWORD=<valor>
FTP_PORT=21
REMOTE_PATH=<valor>
SITE_URL=<valor>
```

### 4.3 — Atualizar package.json

Defina `name` com o slug do cliente (ex: `acme-corp`).

### 4.4 — Substituir valores no template

O template já tem estrutura completa. Faça substituições globais em todos os arquivos de `src/`:

| Placeholder | Substituir por |
|---|---|
| `Nome do Cliente` | Nome real da empresa |
| `nomecliente` | Slug usado no e-mail de contato |
| `business` (keyword loremflickr) | Keyword do segmento |
| Fontes Google (Playfair Display + Source Serif 4) | Par de fontes escolhido |
| URL do Google Fonts | URL gerada para as novas fontes |
| Cores em `:root` no CSS | Hexadecimais confirmados |
| `--radius: 6px` | Valor definido |
| `<meta name="whatsapp-number" content="">` | `content="<número>"` em todas as páginas (se fornecido) |

**Notas específicas por template:**
- **Bold:** o `h1` tem `white-space: nowrap` intencional para o efeito de overflow brutalist. **Não remova.** Se a headline for muito longa, quebre com `<br>` no HTML.
- **Modern:** o hero usa gradientes CSS (`::before`/`::after`). **Não adicione** `<img class="hero-bg">` — é intencional não ter imagem no hero.
- **Minimalist:** o hero usa `.hero-text-pane` + `.hero-image-pane` (layout split-screen). A URL da imagem em `.hero-image-pane img` usa `seed/hero/1200/1600` (retrato) ao invés de `1600/900` (paisagem).

**Nomes de arquivo sem acentos:** renomeie `about.html → sobre.html`, `services.html → servicos.html`, `contact.html → contato.html` se o cliente preferir URLs em português — e atualize todos os `href` correspondentes. Caso contrário, mantenha os nomes em inglês (evita problemas em alguns servidores).

**Ícones — nunca use emoji.** O projeto usa dois tipos de ícone:
- **Ícones de UI** (valores, contato, etc.): SVGs inline com `fill="none"`, `stroke="currentColor"`, `stroke-width="1.5"`, `viewBox="0 0 24 24"`. Siga o padrão já usado em `about.html` e `contact.html`.
- **Ícones sociais no footer**: gerados automaticamente via `simple-icons` em `main.js`. Para adicionar ou remover redes, edite o array `socialLinks` em `src/js/main.js`.

**Páginas extras:** se o cliente pediu páginas além do padrão, crie-as copiando a estrutura de `about.html` (page-hero + section com container), adaptando título e conteúdo lorem ipsum. Adicione o link no `<nav>` e no `footer` de todas as páginas.

**Páginas removidas:** delete os `.html` não solicitados e remova seus links do nav e footer nas páginas restantes.

**Textos de placeholder contextual** — atualize apenas estes campos com texto coerente ao segmento (mantenha o resto em lorem ipsum):
- `<h1>` do hero: headline de impacto de 5–8 palavras
- `<p>` do hero: subtítulo de 1–2 linhas
- Nomes dos 3 serviços na home e dos 6 cards em serviços
- Título e subtítulo do `page-hero` de cada página interna

---

## Fase 5 — Visualização local

O projeto não tem build step — abra os arquivos diretamente no navegador com qualquer servidor HTTP estático. Não execute nenhum comando, apenas apresente as opções:

1. Python Server
```bash
# Python (disponível em qualquer Mac/Linux)
cd ../SLUG/src && python3 -m http.server 8080
```
2. VS Code: instale "Live Server" e clique em "Go Live"


Informe ao usuário:

```
Projeto pronto. Abra http://localhost:8080 no navegador.

Verifique:
  ✓ Cores e fontes aplicadas corretamente
  ✓ Imagens de placeholder coerentes com o segmento
  ✓ Footer fixo no rodapé em todas as páginas
  ✓ Navegação funcionando entre todas as páginas
  ✓ Formulário de contato visualmente correto
  ✓ Botão flutuante do WhatsApp (se número foi fornecido)
  ✓ Layout responsivo (redimensione a janela)

Para publicar: bash scripts/deploy.sh
Para ajustar: descreva aqui o que quer mudar.
```

Se o usuário pedir ajustes, edite os arquivos em `src/` e recarregue o navegador. Continue até aprovação.
