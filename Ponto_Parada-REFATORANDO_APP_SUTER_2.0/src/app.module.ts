import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';

import { Usuario } from './Modules/Entity/Usuario';
import { UsuarioService } from './Modules/Service/Usuario';
import { UsuarioController } from './Modules/Controller/Usuario';

import { Bacias } from './Modules/Entity/Bacias';
import { BaciasService } from './Modules/Service/Bacias';
import { BaciasController } from './Modules/Controller/Bacias';

import { Ras } from './Modules/Entity/Ras';
import { RasService } from './Modules/Service/Ras';
import { RasController } from './Modules/Controller/Ras';

import { RedeVias } from './Modules/Entity/RedeVias';
import { RedeViasService } from './Modules/Service/RedeVias';
import { RedeViasController } from './Modules/Controller/RedeVias';
import { RedeViasRepository } from './Modules/Repository/RedeVias';

import { TipoAbrigo } from './Modules/Entity/TipoAbrigo';
import { TipoAbrigoService } from './Modules/Service/TipoAbrigo';
import { TipoAbrigoController } from './Modules/Controller/TipoAbrigo';

import { ImagensAbrigo } from './Modules/Entity/ImagensAbrigo';
import { ImagensAbrigoService } from './Modules/Service/ImagensAbrigo';
import { ImagensAbrigoController } from './Modules/Controller/ImagensAbrigo';

import { ParadasAntigas } from './Modules/Entity/ParadasAntigas';
import { ParadasAntigasService } from './Modules/Service/ParadasAntigas';
import { ParadasAntigasController } from './Modules/Controller/ParadasAntigas';
import { ParadasAntigasRepository } from './Modules/Repository/ParadasAntigas';

import { TipoPatologia } from './Modules/Entity/TipoPatologia';
import { TipoPatologiaService } from './Modules/Service/TipoPatologia';
import { TipoPatologiaController } from './Modules/Controller/TipoPatologia';

import { PontoParada } from './Modules/Entity/PontoParada';
import { PontoParadaRepository } from './Modules/Repository/PontoParada';
import { PontoParadaService } from './Modules/Service/PontoParada';
import { PontoParadaController } from './Modules/Controller/PontoParada';

import { VisitaRepository } from './Modules/Repository/Cadastro';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST ?? '100.77.74.55',
      port: parseInt(process.env.DB_PORT ?? '5432', 10),
      username: process.env.DB_USERNAME ?? 'postgres',
      password: process.env.DB_PASSWORD ?? '022002',
      database: process.env.DB_DATABASE ?? 'dados_semob',
      /*
      host: process.env.DB_HOST ?? '100.87.130.42',
      port: parseInt(process.env.DB_PORT ?? '5432', 10),
      username: process.env.DB_USERNAME ?? 'gabriel_veras',
      password: process.env.DB_PASSWORD ?? '8yh[K8qOnb7',
      database: process.env.DB_DATABASE ?? 'grupo_agr',
       */
      entities: [
        Usuario,
        Bacias,
        Ras,
        RedeVias,
        TipoAbrigo,
        ImagensAbrigo,
        ParadasAntigas,
        TipoPatologia,
        PontoParada,
      ],
      synchronize: false,
      logging: true,
    }),
    TypeOrmModule.forFeature([
      Usuario,
      Bacias,
      Ras,
      RedeVias,
      TipoAbrigo,
      ImagensAbrigo,
      ParadasAntigas,
      TipoPatologia,
      PontoParada,
      RedeViasRepository,
      ParadasAntigasRepository,
      PontoParadaRepository,
      VisitaRepository,
    ]),
  ],
  controllers: [
    UsuarioController,
    BaciasController,
    RasController,
    RedeViasController,
    TipoAbrigoController,
    ImagensAbrigoController,
    ParadasAntigasController,
    TipoPatologiaController,
    PontoParadaController,
  ],
  providers: [
    UsuarioService,
    BaciasService,
    RasService,
    RedeViasService,
    TipoAbrigoService,
    ImagensAbrigoService,
    ParadasAntigasService,
    TipoPatologiaService,
    PontoParadaService,
    RedeViasRepository,
    ParadasAntigasRepository,
    PontoParadaRepository,
    VisitaRepository,
  ],
})
export class AppModule {}
