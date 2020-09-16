FROM gitpod/workspace-full

WORKDIR /home/gitpod/Downloads

# Update and add Stata dependencies
RUN sudo apt-get update -y && \
  sudo apt-get install libncurses5  -y

RUN sudo wget http://archive.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng_1.2.54.orig.tar.xz && \
  sudo tar xvf libpng_1.2.54.orig.tar.xz && \
  cd libpng-1.2.54 && \
  sudo ./autogen.sh && \
  sudo ./configure && \
  sudo make -j8  && \
  sudo make install && \
  sudo ldconfig

# Add Stata tar package
COPY Stata14Linux64.tar.gz /home/gitpod/Stata14Linux64.tar.gz

# Move Stata to correct folder
RUN sudo mkdir ~/Downloads/statainstall && \
  sudo tar -xvzf ~/Stata14Linux64.tar.gz -C statainstall && \
  sudo mkdir /usr/local/stata14

WORKDIR /usr/local/stata14

# Install Stata and add to PATH
RUN yes Y | sudo ~/Downloads/statainstall/install && \
  echo export PATH="/usr/local/stata14:$PATH" >> ~/.bashrc

# Add license file and cleanup files
RUN wget -O ~/stata.lic "https://raw.githubusercontent.com/jelaniwoods/dotfiles/master/STATA.lic" && \
  cd /usr/local/stata14 && \
  sudo mv ~/stata.lic /usr/local/stata14 && \
  sudo rm -rf ~/Downloads/statainstall && \
  sudo rm -rf /home/gitpod/Stata14Linux64.tar.gz

