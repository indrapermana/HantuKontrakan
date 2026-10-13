import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/simulation/content/incident_definitions.dart';
import 'package:hantu_kontrakan/simulation/models/ghost.dart';
import 'package:hantu_kontrakan/simulation/models/incident_definition.dart';

void main() {
  test('catalog contains the ten planned localized incidents', () {
    expect(IncidentDefinitions.validationErrors(), isEmpty);
    expect(IncidentDefinitions.schedulerPool.map((incident) => incident.id), {
      'pocong_midnight_exercise',
      'tuyul_missing_sandals',
      'pak_rt_complaint',
      'electricity_outage',
      'kuntilanak_karaoke',
      'genderuwo_breaks_furniture',
      'neighborhood_security_patrol',
      'paranormal_content_creator',
      'mysterious_stolen_clothesline',
      'night_market_next_door',
    });
    for (final incident in IncidentDefinitions.schedulerPool) {
      expect(incident.title!.id, isNotEmpty);
      expect(incident.title!.en, isNotEmpty);
      expect(incident.dialogue!.id, isNotEmpty);
      expect(incident.dialogue!.en, isNotEmpty);
      expect(incident.choices.length, inInclusiveRange(2, 3));
      expect(incident.cooldownSeconds, greaterThanOrEqualTo(180));
    }
  });

  test('every choice has stable exact effects and localized response copy', () {
    final actual = <String, String>{};
    for (final incident in IncidentDefinitions.schedulerPool) {
      for (final choice in incident.choices) {
        actual['${incident.id}/${choice.id}'] = _effectSignature(
          choice.effects,
        );
        expect(choice.label.id, isNotEmpty);
        expect(choice.label.en, isNotEmpty);
        expect(choice.response.id, isNotEmpty);
        expect(choice.response.en, isNotEmpty);
      }
    }

    expect(actual, {
      'pocong_midnight_exercise/reinforce_floor':
          'coins=-40;happy=pocong:15;chaos=-2;rep=0',
      'pocong_midnight_exercise/set_exercise_hours':
          'coins=0;happy=pocong:8;chaos=-4;rep=1',
      'tuyul_missing_sandals/buy_new_sandals':
          'coins=-20;happy=tuyul:12;chaos=-2;rep=0',
      'tuyul_missing_sandals/search_every_room':
          'coins=0;happy=pocong:-3,tuyul:5;chaos=2;rep=0',
      'pak_rt_complaint/pay_community_fund':
          'coins=-60;happy=none;chaos=-10;rep=6',
      'pak_rt_complaint/join_patrol': 'coins=0;happy=none;chaos=-6;rep=4',
      'electricity_outage/buy_emergency_lights':
          'coins=-25;happy=genderuwo:5,kuntilanak:5,pocong:5,tuyul:5;chaos=-3;rep=0',
      'electricity_outage/wait_in_the_dark':
          'coins=0;happy=genderuwo:-5,kuntilanak:-5,pocong:-5,tuyul:-5;chaos=2;rep=0',
      'kuntilanak_karaoke/rent_soundproofing':
          'coins=-50;happy=kuntilanak:10;chaos=-3;rep=2',
      'kuntilanak_karaoke/request_encore':
          'coins=0;happy=kuntilanak:15;chaos=5;rep=-2',
      'genderuwo_breaks_furniture/hire_carpenter':
          'coins=-80;happy=genderuwo:10;chaos=-2;rep=2',
      'genderuwo_breaks_furniture/make_him_help':
          'coins=-20;happy=genderuwo:-5;chaos=-1;rep=1',
      'neighborhood_security_patrol/serve_coffee':
          'coins=-30;happy=none;chaos=-4;rep=6',
      'neighborhood_security_patrol/hide_the_ghosts':
          'coins=0;happy=genderuwo:-4,kuntilanak:-4,pocong:-4,tuyul:-4;chaos=-2;rep=1',
      'paranormal_content_creator/allow_filming':
          'coins=50;happy=genderuwo:-3,kuntilanak:-3,pocong:-3,tuyul:-3;chaos=4;rep=-2',
      'paranormal_content_creator/host_guided_tour':
          'coins=30;happy=genderuwo:3,kuntilanak:3,pocong:3,tuyul:3;chaos=2;rep=5',
      'mysterious_stolen_clothesline/replace_clothesline':
          'coins=-35;happy=none;chaos=-3;rep=4',
      'mysterious_stolen_clothesline/follow_the_pegs':
          'coins=0;happy=tuyul:5;chaos=2;rep=2',
      'night_market_next_door/rent_a_stall':
          'coins=40;happy=genderuwo:5,kuntilanak:5,pocong:5,tuyul:5;chaos=5;rep=2',
      'night_market_next_door/negotiate_quiet_hours':
          'coins=-10;happy=none;chaos=-4;rep=3',
    });
  });

  test('lookup returns stable definitions without fallback content', () {
    expect(
      IncidentDefinitions.byId('kuntilanak_karaoke')?.requiredGhostKind,
      GhostKind.kuntilanak,
    );
    expect(IncidentDefinitions.byId('missing'), isNull);
  });
}

String _effectSignature(IncidentEffects effects) {
  final happiness = effects.happinessDeltaByKind.entries.toList()
    ..sort((left, right) => left.key.name.compareTo(right.key.name));
  final happinessText = happiness.isEmpty
      ? 'none'
      : happiness.map((entry) => '${entry.key.name}:${entry.value}').join(',');
  return 'coins=${effects.coinDelta};happy=$happinessText;'
      'chaos=${effects.chaosDelta};rep=${effects.reputationDelta}';
}
