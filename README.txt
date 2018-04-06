Escolhi reestruturar o REFLHEX, um jogo que fiz em Janeiro. Como ele já utilizava estados para controlar o jogo, escolhi implementar os patterns de State e Observer.

Os arquivos modificados foram:
- GameScene.swift (modificado para usar as novas classes de State, observando mudanças por KVO)
- GameStates.swift (criado como classe abstrata para os outros estados)
  * MenuState.swift 
  * RestartState.swift 
  * PlayingState.swift 
  * PausedState.swift 
  * GameOverState.swift 