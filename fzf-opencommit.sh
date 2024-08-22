function fzf-opencommit() {
  ######################
  ### Option Parser
  ######################

  local __parse_options (){
    local prompt="$1" && shift
    local option_list
    if [[ "$SHELL" == *"/bin/zsh" ]]; then
      option_list=("$@")
    elif [[ "$SHELL" == *"/bin/bash" ]]; then
      local -n arr_ref=$1
      option_list=("${arr_ref[@]}")
    fi

    ### Select the option
    selected_option=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="${prompt} > ")
    if [[ -z "$selected_option" || "$selected_option" =~ ^[[:space:]]*$ ]]; then
      return 1
    fi

    ### Normalize the option list
    local option_list_normal=()
    for option in "${option_list[@]}"; do
        # Remove $(tput bold) and $(tput sgr0) from the string
        option_normalized="${option//$(tput bold)/}"
        option_normalized="${option_normalized//$(tput sgr0)/}"
        # Add the normalized string to the new array
        option_list_normal+=("$option_normalized")
    done
    ### Get the index of the selected option
    index=$(printf "%s\n" "${option_list_normal[@]}" | grep -nFx "$selected_option" | cut -d: -f1)
    if [ -z "$index" ]; then
      return 1
    fi

    ### Generate the command
    local command=""
    if [[ "$SHELL" == *"/bin/zsh" ]]; then
      command="${option_list_normal[$index]%%:*}"
    elif [[ "$SHELL" == *"/bin/bash" ]]; then
      command="${option_list_normal[$index-1]%%:*}"
    else
      echo "Error: Unsupported shell. Please use bash or zsh to use fzf-opencommit."
      return 1
    fi
    echo $command
    return 0
  }

  ######################
  ### Print Conventional Commit Types
  ######################

  local __print_conventional_commit_types() {
    echo "
$(tput bold)Quick Examples$(tput sgr0)
  $(tput bold)feat$(tput sgr0):            New feature
  $(tput bold)feat!$(tput sgr0):           Breaking change
  $(tput bold)feat(scope)!$(tput sgr0):    Rework API
  $(tput bold)fix(scope)$(tput sgr0):      Bug in scope
  $(tput bold)chore(deps)$(tput sgr0):     update dependencies

$(tput bold)Commit Types$(tput sgr0)
  $(tput bold)build$(tput sgr0):           Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
  $(tput bold)ci$(tput sgr0):              Changes to CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
  $(tput bold)chore$(tput sgr0):           Changes which doesn't change source code or tests e.g. changes to the build process, auxiliary tools, libraries
  $(tput bold)docs$(tput sgr0):            Documentation only changes
  $(tput bold)feat$(tput sgr0):            A new feature
  $(tput bold)fix$(tput sgr0):             A bug fix
  $(tput bold)perf$(tput sgr0):            A code change that improves performance
  $(tput bold)refactor$(tput sgr0):        A code change that neither fixes a bug nor adds a feature
  $(tput bold)revert$(tput sgr0):          Revert something
  $(tput bold)style$(tput sgr0):           Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
  $(tput bold)test$(tput sgr0):            Adding missing tests or correcting existing tests
"
  }

  ######################
  ### Config Loader
  ######################

  local __get_config() {
    local key=$1
    local default_value=$2
    local config_file="${HOME}/.opencommit"
    if [ -f "${config_file}" ]; then
      local value=$(grep "^${key}=" "${config_file}" | cut -d'=' -f2)
      echo "${value:-undefined}"
      return 0
    else
      echo "${default_value}"
      return 1
    fi
  }

  ######################
  ### OpenCommit - Commit
  ######################

  local __fzf-opencommit-commit() {
    __print_conventional_commit_types
    BUFFER="opencommit"
  }

  local __fzf-opencommit-commit-dry-run() {
    __print_conventional_commit_types
    BUFFER="opencommit --dry-run"
  }

  ######################
  ### OpenCommit - Config - Entry Point
  ######################

  local __fzf-opencommit-config() {
    local option_list=(
        "$(tput bold)OCO_AI_PROVIDER:$(tput sgr0)                     Configure AI provider"
        " "
        "$(tput bold)OCO_OPENAI_API_KEY:$(tput sgr0)                  Configure your OpenAI API token"
        "$(tput bold)OCO_OPENAI_BASE_PATH:$(tput sgr0)                Configure proxy path to OpenAI api"
        "$(tput bold)OCO_MODEL:$(tput sgr0)                           Configure Open AI model"
        "$(tput bold)OCO_ANTHROPIC_API_KEY:$(tput sgr0)               Configure your Anthropic API token"
        "$(tput bold)OCO_AZURE_API_KEY:$(tput sgr0)                   Configure your Azure API token"
        "$(tput bold)OCO_AZURE_ENDPOINT:$(tput sgr0)                  Configure proxy path to Azure api"
        "$(tput bold)OCO_GEMINI_API_KEY:$(tput sgr0)                  Configure your Gemini API token"
        "$(tput bold)OCO_GEMINI_BASE_PATH:$(tput sgr0)                Configure proxy path to Gemini api"
        "$(tput bold)OCO_FLOWISE_API_KEY:$(tput sgr0)                 Configure your FloWise API token"
        "$(tput bold)OCO_FLOWISE_ENDPOINT:$(tput sgr0)                Configure your FloWise API endpoint"

        "$(tput bold)OCO_TOKENS_MAX_INPUT:$(tput sgr0)                Configure max model token limit"
        "$(tput bold)OCO_TOKENS_MAX_OUTPUT:$(tput sgr0)               Configure max response tokens"
        " "
        "$(tput bold)OCO_LANGUAGE:$(tput sgr0)                        Configure locale"
        "$(tput bold)OCO_DESCRIPTION:$(tput sgr0)                     Configure postface a message with ~3 sentences description of the changes"
        "$(tput bold)OCO_ONE_LINE_COMMIT:$(tput sgr0)                 Configure one line commit message"
        "$(tput bold)OCO_EMOJI:$(tput sgr0)                           Configure boolean, add GitMoji"
        "$(tput bold)OCO_GITPUSH:$(tput sgr0)                         Configure git push"
        "$(tput bold)OCO_MESSAGE_TEMPLATE_PLACEHOLDER:$(tput sgr0)    Configure message template placeholder"
        "$(tput bold)OCO_PROMPT_MODULE:$(tput sgr0)                   Configure prompt module"
        " "
        "$(tput bold)Print Configurations:$(tput sgr0)                Print ~/.opencommit"
    )
    local command=$(__parse_options "opencommit" ${option_list[@]})
    if [ $? -eq 1 ]; then; return 1; fi
    case "$command" in
      "OCO_AI_PROVIDER")                  __fzf-opencommit-config-ai-provider;;

      "OCO_OPENAI_API_KEY")               __fzf-opencommit-config-openai-api-key;;
      "OCO_OPENAI_BASE_PATH")             __fzf-opencommit-config-openai-base-path;;
      "OCO_MODEL")                        __fzf-opencommit-config-model;;
      "OCO_ANTHROPIC_API_KEY")            __fzf-opencommit-config-anthropic-api-key;;
      "OCO_AZURE_API_KEY")                __fzf-opencommit-config-azure-api-key;;
      "OCO_AZURE_ENDPOINT")               __fzf-opencommit-config-azure-endpoint;;
      "OCO_GEMINI_API_KEY")               __fzf-opencommit-config-gemini-api-key;;
      "OCO_GEMINI_BASE_PATH")             __fzf-opencommit-config-gemini-base-path;;
      "OCO_FLOWISE_API_KEY")              __fzf-opencommit-config-flowise-api-key;;
      "OCO_FLOWISE_ENDPOINT")             __fzf-opencommit-config-flowise-endpoint;;
      "OCO_OLLAMA_API_URL")               __fzf-opencommit-config-ollama-api-url;;

      "OCO_TOKENS_MAX_INPUT")             __fzf-opencommit-config-tokens-max-input;;
      "OCO_TOKENS_MAX_OUTPUT")            __fzf-opencommit-config-tokens-max-output;;

      "OCO_LANGUAGE")                     __fzf-opencommit-config-language;;
      "OCO_DESCRIPTION")                  __fzf-opencommit-config-description;;
      "OCO_ONE_LINE_COMMIT")              __fzf-opencommit-config-one-line-commit;;
      "OCO_EMOJI")                        __fzf-opencommit-config-emoji;;
      "OCO_GITPUSH")                      __fzf-opencommit-config-git-push;;
      "OCO_MESSAGE_TEMPLATE_PLACEHOLDER") __fzf-opencommit-config-message-template-placeholder;;
      "OCO_PROMPT_MODULE")                __fzf-opencommit-config-prompt-module;;

      "Print Configurations")             __fzf-opencommit-config-print-config;;
      *)                                  BUFFER="echo \"Error: Unknown command '$command\"";;
    esac
    if [ -f ~/.opencommit ]; then
        sort -f ~/.opencommit -o ~/.opencommit
    fi
    return 0
  }

  ######################
  ### OpenCommit - Config - AI Provider
  ######################

  local __fzf-opencommit-config-ai-provider() {
    local current_value=$(__get_config "OCO_AI_PROVIDER" "ollama")
    local option_list=(
        "anthropic"
        "azure"
        "ollama"
    )
    option_list+=($(ollama list | awk 'NR>1 {print $1}' | sort -f))
    local selected_value=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="oco config set OCO_AI_PROVIDER=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_AI_PROVIDER=${selected_value}
        return 0
    else
        echo "No value selected."
        return 1
    fi
  }

  ######################
  ### OpenCommit - Config - Open AI
  ######################

  local __fzf-opencommit-config-openai-api-key() {
    local current_value=$(__get_config "OCO_OPENAI_API_KEY" "undefined")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_OPENAI_API_KEY=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_OPENAI_API_KEY=${selected_value}
    else
      echo "No value selected."
      return 1
    fi
  }

  local __fzf-opencommit-config-openai-base-path() {
    local current_value=$(__get_config "OCO_OPENAI_BASE_PATH" "undefined")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_OPENAI_BASE_PATH=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
      oco config set OCO_OPENAI_BASE_PATH=${selected_value}
      return 0
    else
      echo "No value selected."
      return 1
    fi
  }

  local __fzf-opencommit-config-model() {
    local current_value=$(__get_config "OCO_MODEL" "gpt-4o-mini")
    local option_list=(
        "gpt-4o"
        "gpt-4o-mini"
        "gpt-4"
        "gpt-4-turbo"
        "gpt-3.5-turbo"
        "gpt-3.5-turbo-0125"
        "gpt-4-1106-preview"
        "gpt-4-turbo-preview"
        "gpt-4-0125-preview"
    )
    local selected_value=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="oco config set OCO_MODEL=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_MODEL=${selected_value}
        return 0
    else
        echo "No value selected."
        return 1
    fi
  }

  ######################
  ### OpenCommit - Config - Anthropic
  ######################

  local __fzf-opencommit-config-anthropic-api-key() {
    local current_value=$(__get_config "OCO_ANTHROPIC_API_KEY" "undefined")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_ANTHROPIC_API_KEY=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_ANTHROPIC_API_KEY=${selected_value}
    else
      echo "No value selected."
      return 1
    fi
  }

  ######################
  ### OpenCommit - Config - Azure
  ######################

  local __fzf-opencommit-config-azure-api-key() {
    local current_value=$(__get_config "OCO_AZURE_API_KEY" "undefined")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_AZURE_API_KEY=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_AZURE_API_KEY=${selected_value}
    else
      echo "No value selected."
      return 1
    fi
  }

  local __fzf-opencommit-config-azure-endpoint() {
    local current_value=$(__get_config "OCO_AZURE_ENDPOINT" "undefined")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_AZURE_ENDPOINT=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
      oco config set OCO_AZURE_ENDPOINT=${selected_value}
      return 0
    else
      echo "No value selected."
      return 1
    fi
  }

  ######################
  ### OpenCommit - Config - Gemini
  ######################

  local __fzf-opencommit-config-gemini-api-key() {
    local current_value=$(__get_config "OCO_GEMINI_API_KEY" "undefined")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_GEMINI_API_KEY=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_GEMINI_API_KEY=${selected_value}
    else
      echo "No value selected."
      return 1
    fi
  }

  local __fzf-opencommit-config-gemini-base-path() {
    local current_value=$(__get_config "OCO_GEMINI_BASE_PATH" "undefined")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_GEMINI_BASE_PATH=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
      oco config set OCO_GEMINI_BASE_PATH=${selected_value}
      return 0
    else
      echo "No value selected."
      return 1
    fi
  }

  ######################
  ### OpenCommit - Config - Flowise
  ######################

  local __fzf-opencommit-config-flowise-api-key() {
    local current_value=$(__get_config "OCO_FLOWISE_API_KEY" "undefined")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_FLOWISE_API_KEY=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_FLOWISE_API_KEY=${selected_value}
    else
      echo "No value selected."
      return 1
    fi
  }

  local __fzf-opencommit-config-flowise-endpoint() {
    local current_value=$(__get_config "OCO_FLOWISE_ENDPOINT" ":")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_FLOWISE_ENDPOINT=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
      oco config set OCO_FLOWISE_ENDPOINT=${selected_value}
      return 0
    else
      echo "No value selected."
      return 1
    fi
  }

  ######################
  ### OpenCommit - Config - Ollama
  ######################

  local __fzf-opencommit-config-ollama-api-url() {
    local current_value=$(__get_config "OCO_OLLAMA_API_URL" "undefined")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_OLLAMA_API_URL=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_OLLAMA_API_URL=${selected_value}
    else
      echo "No value selected."
      return 1
    fi
  }

  ######################
  ### OpenCommit - Config - Tokens
  ######################

  local __fzf-opencommit-config-tokens-max-input() {
    local current_value=$(__get_config "OCO_TOKENS_MAX_INPUT" "4096")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_TOKENS_MAX_INPUT=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
      if [[ "${selected_value}" =~ ^[0-9]+$ ]]; then
        oco config set OCO_TOKENS_MAX_INPUT=${selected_value}
        return 0
      else
        echo "Invalid input: ${selected_value}"
        return 1
      fi
    else
      echo "No value selected."
      return 1
    fi
  }

  local __fzf-opencommit-config-tokens-max-output() {
    local current_value=$(__get_config "OCO_TOKENS_MAX_OUTPUT" "500")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_TOKENS_MAX_OUTPUT=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
      if [[ "${selected_value}" =~ ^[0-9]+$ ]]; then
        oco config set OCO_TOKENS_MAX_OUTPUT=${selected_value}
        return 0
      else
        echo "Invalid input: ${selected_value}"
        return 1
      fi
    else
      echo "No value selected."
      return 1
    fi
  }

  ######################
  ### OpenCommit - Config - Misc
  ######################

  local __fzf-opencommit-config-language() {
    local current_value=$(__get_config "OCO_LANGUAGE" "en")
    local option_list=(
        "cs:       Czech"
        "de:       German"
        "en:       English"
        "es_ES:    Spanish"
        "fr:       French"
        "id_ID:    Indonesian"
        "it:       Italian"
        "ja:       Japanese"
        "ko:       Korean"
        "nl:       Dutch"
        "pl:       Polish"
        "pt_br:    Portuguese"
        "ru:       Russian"
        "sv:       Swedish"
        "th:       Thai"
        "tr:       Turkish"
        "vi_VN:    Vietnamese"
        "zh_CN:    Chinese (Simplified)"
        "zh_TW:    Chinese (Traditional)"
    )
    local selected_value=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="oco config set OCO_LANGUAGE=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        local selected_key="${selected_value%%:*}"
        oco config set OCO_LANGUAGE=${selected_value}
        return 0
    else
        echo "No value selected."
        return 1
    fi
  }

  local __fzf-opencommit-config-description() {
    local current_value=$(__get_config "OCO_DESCRIPTION" "false")
    local option_list=(
        "true"
        "false"
    )
    local selected_value=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="oco config set OCO_DESCRIPTION=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_DESCRIPTION=${selected_value}
        return 0
    else
        echo "No value selected."
        return 1
    fi
  }

  local __fzf-opencommit-config-one-line-commit() {
    local current_value=$(__get_config "OCO_ONE_LINE_COMMIT" "false")
    local option_list=(
        "true"
        "false"
    )
    local selected_value=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="oco config set OCO_ONE_LINE_COMMIT=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_ONE_LINE_COMMIT=${selected_value}
        return 0
    else
        echo "No value selected."
        return 1
    fi
  }

  local __fzf-opencommit-config-emoji() {
    BUFFER="OCO_EMOJI='<BOOLEAN>' opencommit"
    local current_value=$(__get_config "OCO_EMOJI" "false")
    local option_list=(
        "true"
        "false"
    )
    local selected_value=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="oco config set OCO_EMOJI=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_EMOJI=${selected_value}
        return 0
    else
        echo "No value selected."
        return 1
    fi
  }

  local __fzf-opencommit-config-git-push() {
    local current_value=$(__get_config "OCO_GITPUSH" "true")
    local option_list=(
        "true"
        "false"
    )
    local selected_value=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="oco config set OCO_GITPUSH=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_GITPUSH=${selected_value}
        return 0
    else
        echo "No value selected."
        return 1
    fi
  }

  local __fzf-opencommit-config-message-template-placeholder() {
    local current_value=$(__get_config "OCO_MESSAGE_TEMPLATE_PLACEHOLDER" "conventional-commit")
    local selected_value=$(fzf --ansi --pointer="" --no-mouse --marker="" --disabled --print-query --no-separator --no-info --layout=reverse-list --height=~100% --prompt="oco config set OCO_MESSAGE_TEMPLATE_PLACEHOLDER=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
      oco config set OCO_MESSAGE_TEMPLATE_PLACEHOLDER=${selected_value}
      return 0
    else
      echo "No value selected."
      return 1
    fi
  }

  local __fzf-opencommit-config-prompt-module() {
    local current_value=$(__get_config "OCO_PROMPT_MODULE" "conventional-commit")
    local option_list=(
        "@commitlint"
        "conventional-commit"
    )
    local selected_value=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="oco config set OCO_PROMPT_MODULE=<VALUE> (current value: ${current_value}) > ")
    if [ -n "${selected_value}" ]; then
        oco config set OCO_PROMPT_MODULE=${selected_value}
        return 0
    else
        echo "No value selected."
        return 1
    fi
  }

  ######################
  ### OpenCommit - Config - Print Config
  ######################

  local __fzf-opencommit-config-print-config() {
    if [ -f ~/.opencommit ]; then
        cat ~/.opencommit
    else
        echo "Error: No configurations set."
    fi
  }

  ######################
  ### Entry Point
  ######################

  local init() {
    local option_list=(
      "$(tput bold)commit:$(tput sgr0)      Execute \`opencommit\` command."
      "$(tput bold)dry run:$(tput sgr0)     Execute \`opencommit --dry-run\` command."
      " "
      "$(tput bold)config:$(tput sgr0)      configure OpenCommit."
    )
    command=$(__parse_options "opencommit" ${option_list[@]})
    if [ $? -eq 1 ]; then
        zle accept-line
        zle -R -c
        return 1
    fi
    case "$command" in
      "commit")     __fzf-opencommit-commit;;
      "dry run")    __fzf-opencommit-commit-dry-run;;
      "config")     __fzf-opencommit-config;;
      *)            BUFFER="echo \"Error: Unknown command '$command\"";;
    esac

    zle accept-line
    zle -R -c
  }

  init
}

zle -N fzf-opencommit
bindkey "${FZF_OPENCOMMIT_KEY_BINDING}" fzf-opencommit