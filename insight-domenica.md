# Dalla CNS bloccata a una diagnosi condivisibile

Un accesso pubblico rimaneva fermo dopo la scelta del certificato CNS. La carta era leggibile e il PIN veniva accettato, ma questo non garantiva che la comunicazione con il lettore fosse completa. Abbiamo confrontato browser e reti, quindi individuato errori USB nei registri del Mac e cercato segnalazioni sul chip del lettore.

Il punto di svolta è stato trovare il lavoro pubblico di Ludovic Rousseau e dei contributori del progetto CCID su quel modello Alcor. Abbiamo compilato una versione più recente del loro driver, ristretto il dispositivo interessato e predisposto una via di ripristino. Su un Mac Apple Silicon con macOS 26.6.2, l'accesso è poi riuscito sia con Firefox sia con Safari.

L'AI ha aiutato a collegare i sintomi, cercare fonti, preparare una prova e documentare i passaggi. La verifica decisiva è stata pratica: l'area riservata si è aperta davvero. La correzione nel driver era già opera del progetto originale; il nostro contributo è averla applicata e documentata per questo caso. Un risultato su una macchina non dimostra la compatibilità universale: per estenderla servono prove su altri Mac, lettori e carte.
