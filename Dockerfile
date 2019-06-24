FROM archlinux/base:latest

ENV USER pwn

# Installing yay
RUN echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf && \
    pacman -Syyu --noconfirm && \
    pacman -S base-devel lib32-glibc git zsh --noconfirm
RUN sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    useradd -m -g users -G wheel -s /usr/bin/zsh $USER && \
    touch /home/$USER/.zshrc
USER $USER
WORKDIR /home/$USER
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm

# Installing oh my zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
COPY ./zshrc /home/$USER/.zshrc
COPY ./agnoster-dracula.zsh-theme /home/$USER/.oh-my-zsh/custom/themes/agnoster-dracula.zsh-theme

# Installing QoL stuff
RUN yay -S neovim exa wget bat fzf ripgrep tmux autojump strace net-tools iputils wget ltrace \
    python-pip python-virtualenv unzip unrar pigz p7zip --noconfirm && \
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs\
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    mkdir -p /home/$USER/.config/nvim
COPY ./init.vim /home/$USER/.config/nvim
RUN sed '/call plug#end/q' /home/$USER/.config/nvim/init.vim > /home/$USER/.config/nvim/temp.vim && \
    nvim -u /home/$USER/.config/nvim/temp.vim -c ':PlugInstall' -c ':qall' && \
    rm -f /home/$USER/.config/nvim/temp.vim

# Change permissions
RUN sudo chown $USER:users /home/$USER/.zshrc \
    /home/$USER/.oh-my-zsh/custom/themes/agnoster-dracula.zsh-theme \
    /home/$USER/.config/nvim/init.vim

# Cleanup
RUN yay -Scc --noconfirm && \
    rm -rvf /home/$USER/yay /home/$USER/.zshrc.pre-oh-my-zsh \
           /home/$USER/.zsh_history /home/$USER/.bash_profile \
           /home/$USER/.bash_logout /home/$USER/.cache

# Start in zsh
ENTRYPOINT ["/usr/bin/zsh"]
