---
title: Problemas de ‘Permission denied (publickey)’ no github ao tentar realizar pull e push no Windows XP
author: Aécio Santos
permalink: /2009/12/08/problemas-de-permission-denied-publickey-no-github-ao-tentar-realizar-pull-e-push-no-windows-xp/
#published_time: December 8, 2009
published_time: 2009-12-08T05:16:36+00:00
modified_time: 2009-12-08T05:16:36+00:00
content_type: markdown
---

# Problemas de ‘Permission denied (publickey)’ no github ao tentar realizar pull e push no Windows XP
*December 8, 2009*

Ontem perdi um bom tempo tentando configurar um projeto no GitHub. Estava ocorrendo uns erros de autenticação (*Permission denied*) ao tentar fazer pull ou push.

Depois de muitas buscas na web e não encontrar nada, descobri que o erro estava sendo causado por codificação de caracteres. O nome da minha conta de usuário no Windows era "Aécio" e por algum motivo o Git não reconhecia o acento do nome. Ao chamar o comando `ssh-keygen` para gerar a chave de autenticação, ao invés do Git gerar a chave dentro da pasta de usuário padrão `C:\Documents and Settings\Aécio.ssh`, ele estava criando outra pasta com nome `C:\Documents and Settings\A’cio.ssh`. Consegui adicionar a chave gerada no GitHub (foi aceita sem problemas). Até consegui fazer o primeiro push em um projeto, mas depois apareceram alguns erros ao tentar fazer push. Tentei gerar a chave SSH em outra pasta, mas o problema continuava.

Só depois de muito tempo consegui resolver o problema mudando o nome do usuário para outro sem "caracteres especiais". Mudar o nome de Usuário no `Painel de Controle -> Contas de usuário` não adianta. Só muda o nome que aparece no menu iniciar e na inicialização. Para mudar é necessário fazer mudanças no registro do sistema e renomear a pasta de usuário manualmente. Existe alguns tutoriais sobre como fazer isso na internet.

Fica a dica pra quem se deparar com o mesmo problema. Uma dica melhor ainda é usar Linux (consegui configurar tudo sem problemas em menos de 10 minutos =).

Se você conseguiu resolver este problema de outra forma, me deixe saber.

Alguns links que podem ajudar:

- [Criação de chaves SSH (Generating SSH keys)](http://github.com/guides/addressing-authentication-problems-with-ssh)
- [Resolvendo problemas de autenticação com SSH (Addressing authentication problems with SSH)](http://github.com/guides/addressing-authentication-problems-with-ssh)
