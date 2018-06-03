FROM gcr.io/learned-stone-189802/base-ide:latest

ENV \
    PHPBREW_VERSION=1.23.1 \
    PHPBREW_ROOT=/home/user/php/src/.phpbrew \
    PHPBREW_HOME=/home/user/php/src/.phpbrew \
    PATH="/home/user/php/src/.phpbrew:/home/user/php/src/composer:$PATH" \
    COMPOSER_VERSION=fe44bd5b10b89fbe7e7fc70e99e5d1a344a683dd

# INSTALL 
RUN sudo apt-get update && \
    sudo apt-get -qq install --no-install-recommends -y \
        wget \
        php7.0 \
        php7.0-curl \
        php7.0-json \
        php7.0-cgi \
        php7.0-fpm \
        autoconf \
        automake \
        libxml2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        gettext \
        libicu-dev \
        libmcrypt-dev \
        libmcrypt4 \
        libbz2-dev \
        libreadline-dev \
        libmhash-dev \
        libmhash2 \
        libxslt1-dev \
        zlib1g-dev \
        && \
        sudo apt-get clean && \
        sudo rm -rf /var/lib/apt/lists/*

RUN sudo ln -s /usr/include/x86_64-linux-gnu/curl /usr/local/include/curl

#INSTALL phpbrew
#INSTALL php
RUN mkdir -p "$PHPBREW_ROOT" && \
    curl -L https://github.com/phpbrew/phpbrew/archive/"$PHPBREW_VERSION".tar.gz | \
    tar -C "$PHPBREW_ROOT" -zx phpbrew-"$PHPBREW_VERSION"/phpbrew --strip=1 && \
    chmod +x "$PHPBREW_ROOT"/phpbrew && \
    "$PHPBREW_ROOT"/phpbrew init --root="$PHPBREW_ROOT" && \
    "$PHPBREW_ROOT"/phpbrew update 

# INSTALL composer
RUN mkdir -p /home/user/php/src/composer && \
    wget https://raw.githubusercontent.com/composer/getcomposer.org/"$COMPOSER_VERSION"/web/installer -O - -q | \
    php -- --quiet --install-dir=/home/user/php/src/composer

# INSTALL php-cs-fixer
#RUN /home/user/php/src/composer/composer global require friendsofphp/php-cs-fixer
 
#INSTALL vim plugins: 
# php.vim (syntax highlighting)
# vim-php-cs-fixer (auto-fixing issues/formatting whitespace)
# phpcomplete.vim (omni-completion)
RUN git clone https://github.com/StanAngeloff/php.vim.git ~/.vim/bundle/php.vim && \
    git clone https://github.com/stephpy/vim-php-cs-fixer.git ~/.vim/bundle/vim-php-cs-fixer && \ 
    git clone https://github.com/shawncplus/phpcomplete.vim.git ~/.vim/bundle/phpcomplete.vim.git && \
    #SETUP YCM
    cd /home/user/.vim/bundle/YouCompleteMe && \
    ./install.py 

COPY --chown=1000:1000 \
    .entrypoint.sh \
    /home/user/

VOLUME ["/home/user/php/src"]

ENTRYPOINT ["/home/user/.entrypoint.sh"]

LABEL \
    NAME="tahurt/php-ide" \
    RUN="docker run -it --rm --mount type=volume,source=php-src,target=/home/user/php/src --mount type=bind,source=\$HOME/Dropbox/Mackup,target=/home/user/Mackup tahurt/php-ide" \
    RUN_WITH_SSH_AGENT="docker run -it --rm --mount type=volume,source=php-src,target=/home/user/php/src --mount type=bind,source=\$HOME/Dropbox/Mackup,target=/home/user/Mackup --mount type=bind,source=\$SSH_AUTH_SOCK,target=/tmp/ssh_auth.sock --env SSH_AUTH_SOCK=/tmp/ssh_auth.sock tahurt/php-ide" \
    MAINTAINER="taylor.a.hurt@gmail.com"
