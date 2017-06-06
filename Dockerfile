FROM ubuntu:16.04
MAINTAINER voyagerwoo

LABEL "name"="ubuntu_tesseract"

RUN apt-get update

# 기본 툴 설치
RUN apt-get install -y curl && apt-get install -y wget && apt-get install -y git

# Node js 설치
ENV NODE_VERSION 6.10.3
ENV NODE_DIR /opt/nodejs

RUN mkdir ${NODE_DIR} && \
	curl -L https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz | tar xvzf - -C ${NODE_DIR} --strip-components=1

ENV PATH $PATH:${NODE_DIR}/bin

# Tesseract 의존 라이브러리 설치
RUN apt-get install -y g++ && \
    apt-get install -y autoconf automake libtool && \
    apt-get install -y autoconf-archive && \
    apt-get install -y pkg-config && \
    apt-get install -y libpng12-dev && \
    apt-get install -y libjpeg8-dev && \
    apt-get install -y libtiff5-dev && \
    apt-get install -y zlib1g-dev && \
    apt-get install -y libicu-dev && \
    apt-get install -y libpango1.0-dev && \
    apt-get install -y libcairo2-dev

# leptonica 1.74 버전 설치 및 빌드
WORKDIR /
RUN wget http://www.leptonica.org/source/leptonica-1.74.1.tar.gz && tar xvzf leptonica-1.74.1.tar.gz
WORKDIR leptonica-1.74.1
RUN ./configure; make; make install
WORKDIR /

# Tesseract 다운로드 및 설치
RUN git clone https://github.com/tesseract-ocr/tesseract.git
WORKDIR tesseract
RUN ./autogen.sh && ./configure && \
    LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make && \
    make install && ldconfig

# default traning data download
WORKDIR /usr/local/share/tessdata/
RUN wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/eng.traineddata && \
    wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/kor.traineddata

WORKDIR /

RUN apt-get clean && \
	apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*