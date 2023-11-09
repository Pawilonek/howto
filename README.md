# howto

`howto` is a program that uses power of the OpenAI to quickly generate CLI commands based on a description of what you want to happen. Everything without switching context from the console your working on.

![Demo](.github/demo.gif "usage demo")

## Instalation

### Dependencies

 - [curl](https://curl.se/docs/manpage.html)
 - [jq](https://jqlang.github.io/jq/)

### Steps

Clone the repository

```bash
sudo git clone https://github.com/Pawilonek/howto.git /opt/howto
```

Create a symlink to use this command globally:

```bash
sudo ln -s /opt/howto/howto.sh /usr/local/bin/howto
```

Use the command for the first time and pass the OpenAI API key.

```bash
howto
```

### Configuration

After the first run of the command there will be created default config file. Where you can setup used OpenAI model and your API key.

```bash
cat /opt/howto/.env
```

