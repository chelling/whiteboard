require 'nokogiri'
require 'open-uri'
require 'aws-sdk'

task :find_player_ranks => :environment do
  client = Aws::DynamoDB::Client.new(
      region: 'us-east-1',
      access_key_id: 'AKIAIMKDIK3CYIZ762DQ',
      secret_access_key: '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'
  )
  resp = client.scan({
       table_name: '5_Stat_MLB'
   })

  obp = []
  hr = []
  rbi = []
  era = []
  war = []

  resp.items.map do |item|
    i = 1
    while(i <= 5)
      if item["stat_" + i.to_s] == 'OBP'
        obp << item["stat_" + i.to_s + "_value"].to_f
      elsif item["stat_" + i.to_s] == 'HR'
        hr << item["stat_" + i.to_s + "_value"].to_f
      elsif item["stat_" + i.to_s] == 'RBI'
        rbi << item["stat_" + i.to_s + "_value"].to_f
      elsif item["stat_" + i.to_s] == 'ERA'
        era << item["stat_" + i.to_s + "_value"].to_f
      elsif item["stat_" + i.to_s] == 'WAR'
        war << item["stat_" + i.to_s + "_value"].to_f
      end
      i += 1
    end
  end

  obp = obp.sort
  hr = hr.sort
  rbi = rbi.sort
  era = era.sort.reverse
  war = war.sort

  resp.items.map do |item|
    score = []
    i = 1
    while(i <= 5)
      x = []
      if item["stat_" + i.to_s] == 'OBP'
        x = obp
      elsif item["stat_" + i.to_s] == 'HR'
        x = hr
      elsif item["stat_" + i.to_s] == 'RBI'
        x = rbi
      elsif item["stat_" + i.to_s] == 'ERA'
        x = era
      elsif item["stat_" + i.to_s] == 'WAR'
        x = war
      end

      j = 1
      x.map do |val|
        if item["stat_" + i.to_s + "_value"].to_f == val
          score[i] = j
          break
        end
        j += 1
      end
      i += 1
    end

    resp = client.update_item({
        table_name: '5_Stat_MLB',
        key: {
            "User" => item["User"],
            "Year" => item["Year"]
        },
        attribute_updates: {
            "stat_1_score" => {
                value: score[1],
                action: "PUT"
            },
            "stat_2_score" => {
                value: score[2],
                action: "PUT"
            },
            "stat_3_score" => {
                value: score[3],
                action: "PUT"
            },
            "stat_4_score" => {
                value: score[4],
                action: "PUT"
            },
            "stat_5_score" => {
                value: score[5],
                action: "PUT"
            }
        }
     })
  end
end

task :update_players => :environment do
  client = Aws::DynamoDB::Client.new(
      region: 'us-east-1',
      access_key_id: 'AKIAIMKDIK3CYIZ762DQ',
      secret_access_key: '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'
  )
  resp = client.scan({
                         table_name: '5_Stat_MLB'
  })

  resp.items.map do |item|
    i = 1
    while(i <= 5)
      if item["stat_" + i.to_s + "_player"].present? && item["stat_" + i.to_s + "_url"].present? && item["stat_" + i.to_s]
        if item["stat_" + i.to_s + "_player_position"] == "field"
          find_field_player_and_update(item["stat_" + i.to_s + "_player"],
                                       item["stat_" + i.to_s + "_url"],
                                       client,
                                       item["User"], "stat_" + i.to_s,
                                       item["stat_" + i.to_s],
                                       item["stat_" + i.to_s + "_player_position"],
                                       item["stat_" + i.to_s + "_war_url"])
        else
          find_pitcher_player_and_update(item["stat_" + i.to_s + "_player"],
                                         item["stat_" + i.to_s + "_url"],
                                         client,
                                         item["User"], "stat_" + i.to_s,
                                         item["stat_" + i.to_s],
                                         item["stat_" + i.to_s + "_player_position"],
                                         item["stat_" + i.to_s + "_war_url"])
        end
      end
      i += 1
    end
  end
end

def find_field_player_and_update(player_name, player_url, client, user, stat_string, stat, position, war_url)
  dynamodb_stat_hash = {'ab' => "AB", 'bb' => "BB", 'date_game' => "Date", 'team_game_num' => 'Game',
  'h' => 'H', 'hbp' => 'HBP', 'hr' => 'HR', 'opp_id' => 'Opponent', 'r' => 'R', 'rbi' => 'RBI',
  'game_result' => 'Score', 'sf' => 'SF', 'war' => 'WAR', 'ibb' => 'IBB'}
  stats = ['ab','bb','ibb','date_game','team_game_num','h','hbp','hr','opp_id',
           'r','rbi','game_result','sf']
  batting_categories = []
  stat_columns = []
  gamelog = []
  gamelog_final = []

  last_1 = Hash.new
  last_2 = Hash.new
  last_3 = Hash.new
  last_4 = Hash.new
  last_5 = Hash.new
  last_7 = Hash.new
  last_30 = Hash.new
  season = Hash.new
  doc = Nokogiri::HTML(open(player_url))

  # find the columns of the stats
  doc.css("#batting_gamelogs thead").each do |thead|
    thead.css("th").each do |th|
      batting_categories << th["data-stat"].downcase
    end
  end

  # find the column number we care about
  i = 0
  batting_categories.map do |cat|
    stats.map do |stat|
      if stat == cat
        stat_columns << i
      end
    end
    i += 1
  end

  # loop through stats
  doc.css("#batting_gamelogs tr").each do |tr|
    game = []
    tr.css('td').each do |td|
      game << td.text
    end
    gamelog << game
  end

  # loop through games and get totals
  gamelog.map do |game|
    if game.present?
      game_hash = Hash.new
      stat_columns.map do |j|
        game_hash[dynamodb_stat_hash[batting_categories[j]]] = (game[j] || "0")
      end
      #game_hash["BB"] = game_hash["BB"].to_i + game_hash["IBB"].to_i
      gamelog_final << game_hash
    end
  end

  # Calculate last 7, last 30, season totals
  last_7_bb = 0
  last_7_h = 0
  last_7_ab = 0
  last_7_hr = 0
  last_7_rbi = 0
  last_7_hbp = 0
  last_7_sf = 0
  last_30_bb = 0
  last_30_h = 0
  last_30_ab = 0
  last_30_hr = 0
  last_30_rbi = 0
  last_30_hbp = 0
  last_30_sf = 0
  season_bb = 0
  season_h = 0
  season_ab = 0
  season_hr = 0
  season_rbi = 0
  season_hbp = 0
  season_sf = 0
  i = 1
  gamelog_final.reverse.map do |game|
    if game["Game"].present?
      if i == 1
        last_5["score"] = game["Score"].to_s
        last_5["opponent"] = game["Opponent"].to_s
        last_5["game"] = game["Date"].to_s
        last_5["bb"] = game["BB"].to_s
        last_5["h"] = game["H"].to_s
        last_5["ab"] = game["AB"].to_s
        last_5["h_ab"] = game["H"].to_s + "/" + game["AB"].to_s
        last_5["hr"] = game["HR"].to_s
        last_5["rbi"] = game["RBI"].to_s
        last_5["hbp"] = game["HBP"].to_i
        last_5["sf"] = game["SF"].to_i
        last_5["obp"] = ("%.3f" % ((last_5["bb"].to_i + last_5["h"].to_i + last_5["hbp"].to_i) / (last_5["ab"].to_f + last_5["bb"].to_i + last_5["hbp"].to_i + last_5["sf"].to_i)))
        last_5["war"] = "--"
      end

      if i == 2
        last_4["score"] = game["Score"].to_s
        last_4["opponent"] = game["Opponent"].to_s
        last_4["game"] = game["Date"].to_s
        last_4["bb"] = game["BB"].to_s
        last_4["h"] = game["H"].to_s
        last_4["ab"] = game["AB"].to_s
        last_4["h_ab"] = game["H"].to_s + "/" + game["AB"].to_s
        last_4["hr"] = game["HR"].to_s
        last_4["rbi"] = game["RBI"].to_s
        last_4["hbp"] = game["HBP"].to_i
        last_4["sf"] = game["SF"].to_i
        last_4["obp"] = ("%.3f" % ((last_4["bb"].to_i + last_4["h"].to_i + last_4["hbp"].to_i) / (last_4["ab"].to_f + last_4["bb"].to_i + last_4["hbp"].to_i + last_4["sf"].to_i)))
        last_4["war"] = "--"
      end

      if i == 3
        last_3["score"] = game["Score"].to_s
        last_3["opponent"] = game["Opponent"].to_s
        last_3["game"] = game["Date"].to_s
        last_3["bb"] = game["BB"].to_s
        last_3["h"] = game["H"].to_s
        last_3["ab"] = game["AB"].to_s
        last_3["h_ab"] = game["H"].to_s + "/" + game["AB"].to_s
        last_3["hr"] = game["HR"].to_s
        last_3["rbi"] = game["RBI"].to_s
        last_3["hbp"] = game["HBP"].to_i
        last_3["sf"] = game["SF"].to_i
        last_3["obp"] = ("%.3f" % ((last_3["bb"].to_i + last_3["h"].to_i + last_3["hbp"].to_i) / (last_3["ab"].to_f + last_3["bb"].to_i + last_3["hbp"].to_i + last_3["sf"].to_i)))
        last_3["war"] = "--"
      end

      if i == 4
        last_2["score"] = game["Score"].to_s
        last_2["opponent"] = game["Opponent"].to_s
        last_2["game"] = game["Date"].to_s
        last_2["bb"] = game["BB"].to_s
        last_2["h"] = game["H"].to_s
        last_2["ab"] = game["AB"].to_s
        last_2["h_ab"] = game["H"].to_s + "/" + game["AB"].to_s
        last_2["hr"] = game["HR"].to_s
        last_2["rbi"] = game["RBI"].to_s
        last_2["hbp"] = game["HBP"].to_i
        last_2["sf"] = game["SF"].to_i
        last_2["obp"] = ("%.3f" % ((last_2["bb"].to_i + last_2["h"].to_i + last_2["hbp"].to_i) / (last_2["ab"].to_f + last_2["bb"].to_i + last_2["hbp"].to_i + last_2["sf"].to_i)))
        last_2["war"] = "--"
      end

      if i == 5
        last_1["score"] = game["Score"].to_s
        last_1["opponent"] = game["Opponent"].to_s
        last_1["game"] = game["Date"].to_s
        last_1["bb"] = game["BB"].to_s
        last_1["h"] = game["H"].to_s
        last_1["ab"] = game["AB"].to_s
        last_1["h_ab"] = game["H"].to_s + "/" + game["AB"].to_s
        last_1["hr"] = game["HR"].to_s
        last_1["rbi"] = game["RBI"].to_s
        last_1["hbp"] = game["HBP"].to_i
        last_1["sf"] = game["SF"].to_i
        last_1["obp"] = ("%.3f" % ((last_1["bb"].to_i + last_1["h"].to_i + last_1["hbp"].to_i) / (last_1["ab"].to_f + last_1["bb"].to_i + last_1["hbp"].to_i + last_1["sf"].to_i)))
        last_1["war"] = "--"
      end

      if i <= 7
        last_7_bb += game["BB"].to_i
        last_7_h += game["H"].to_i
        last_7_ab += game["AB"].to_i
        last_7_hr += game["HR"].to_i
        last_7_rbi += game["RBI"].to_i
        last_7_hbp += game["HBP"].to_i
        last_7_sf += game["SF"].to_i
      end

      if i <= 30
        last_30_bb += game["BB"].to_i
        last_30_h += game["H"].to_i
        last_30_ab += game["AB"].to_i
        last_30_hr += game["HR"].to_i
        last_30_rbi += game["RBI"].to_i
        last_30_hbp += game["HBP"].to_i
        last_30_sf += game["SF"].to_i
      end

      season_bb += game["BB"].to_i
      season_h += game["H"].to_i
      season_ab += game["AB"].to_i
      season_hr += game["HR"].to_i
      season_rbi += game["RBI"].to_i
      season_hbp += game["HBP"].to_i
      season_sf += game["SF"].to_i
      i += 1
    end
  end

  # Fill out hashes
  last_7["bb"] = last_7_bb
  last_7["h"] = last_7_h
  last_7["ab"] = last_7_ab
  last_7["hr"] = last_7_hr
  last_7["rbi"] = last_7_rbi
  last_7["h_ab"] = last_7["h"].to_s + "/" + last_7["ab"].to_s
  last_7["obp"] = ("%.3f" % ((last_7_bb.to_i + last_7_h.to_i + last_7_hbp.to_i) / (last_7_ab.to_f + last_7_bb.to_i + last_7_hbp.to_i + last_7_sf.to_i)))
  last_7["war"] = "--"
  last_30["bb"] = last_30_bb
  last_30["h"] = last_30_h
  last_30["ab"] = last_30_ab
  last_30["hr"] = last_30_hr
  last_30["rbi"] = last_30_rbi
  last_30["h_ab"] = last_30["h"].to_s + "/" + last_30["ab"].to_s
  last_30["obp"] = ("%.3f" % ((last_30_bb.to_i + last_30_h.to_i + last_30_hbp.to_i) / (last_30_ab.to_f + last_30_bb.to_i + last_30_hbp.to_i + last_30_sf.to_i)))
  last_30["war"] = "--"
  season["bb"] = season_bb
  season["h"] = season_h
  season["ab"] = season_ab
  season["hr"] = season_hr
  season["rbi"] = season_rbi
  season["hbp"] = season_hbp
  season["sf"] = season_sf
  season["h_ab"] = season["h"].to_s + "/" + season["ab"].to_s
  season["obp"] = ("%.3f" % ((season_bb.to_i + season_h.to_i + season_hbp.to_i) / (season_ab.to_f + season_bb.to_i + season_hbp.to_i + season_sf.to_i)))
  season["war"] = find_player_war(war_url, position)

  # create gamelog
  stat_gamelog = Hash.new
  stat_gamelog["player"] = player_name
  stat_gamelog["position"] = "field"
  stat_gamelog["stat"] = stat
  i = 0
  if last_1
    stat_gamelog["game1"] = last_5
    i += 1
  end
  if last_2
    stat_gamelog["game1"] = last_4
    stat_gamelog["game2"] = last_5
    i += 1
  end
  if last_3
    stat_gamelog["game1"] = last_3
    stat_gamelog["game2"] = last_4
    stat_gamelog["game3"] = last_5
    i += 1
  end
  if last_4
    stat_gamelog["game1"] = last_2
    stat_gamelog["game2"] = last_3
    stat_gamelog["game3"] = last_4
    stat_gamelog["game4"] = last_5
    i += 1
  end
  if last_5
    stat_gamelog["game1"] = last_1
    stat_gamelog["game2"] = last_2
    stat_gamelog["game3"] = last_3
    stat_gamelog["game4"] = last_4
    stat_gamelog["game5"] = last_5
    i += 1
  end

  stat_gamelog["last_seven"] = last_7
  stat_gamelog["last_thirty"] = last_30
  stat_gamelog["season"] = season
  stat_gamelog["game_count"] = i

  resp = client.update_item({
       table_name: '5_Stat_MLB',
       key: {
           "User" => user,
           "Year" => 2016
       },
       attribute_updates: {
           stat_string + "_value" => {
               value: season[stat.downcase].to_f.round(3),
               action: "PUT"
           },
           stat_string + "_gamelog" => {
               value: stat_gamelog,
               action: "PUT"
           }
       }
   })
end

def find_pitcher_player_and_update(player_name, player_url, client, user, stat_string, stat, position, war_url)
  dynamodb_stat_hash = {'ip' => "IP", 'bb' => "BB", 'date_game' => "Date", 'team_game_num' => 'Game',
                        'h' => 'H', 'hbp' => 'HBP', 'hr' => 'HR', 'opp_id' => 'Opponent', 'r' => 'R', 'er' => 'ER',
                        'game_result' => 'Score', 'so' => 'SO', 'war' => 'WAR',
                        'earned_run_avg' => 'ERA', 'player_game_result' => 'DEC'}
  stats = ['ip','bb','date_game','team_game_num','h','hbp','hr','opp_id', 'so',
           'r','er','game_result','earned_run_avg', 'player_game_result']
  pitching_categories = []
  stat_columns = []
  gamelog = []
  gamelog_final = []

  last_1 = Hash.new
  last_2 = Hash.new
  last_3 = Hash.new
  last_4 = Hash.new
  last_5 = Hash.new
  last_7 = Hash.new
  last_30 = Hash.new
  season = Hash.new
  doc = Nokogiri::HTML(open(player_url))

  # find the columns of the stats
  doc.css("#pitching_gamelogs thead").each do |thead|
    thead.css("th").each do |th|
      pitching_categories << th["data-stat"].downcase
    end
  end

  # find the column number we care about
  i = 0
  pitching_categories.map do |cat|
    stats.map do |stat|
      if stat == cat
        stat_columns << i
      end
    end
    i += 1
  end

  # loop through stats
  doc.css("#pitching_gamelogs tr").each do |tr|
    game = []
    tr.css('td').each do |td|
      game << td.text
    end
    gamelog << game
  end

  # loop through games and get totals
  gamelog.map do |game|
    if game.present?
      game_hash = Hash.new
      stat_columns.map do |j|
        game_hash[dynamodb_stat_hash[pitching_categories[j]]] = (game[j] || "0")
      end
      gamelog_final << game_hash
    end
  end

  # Calculate last 7, last 30, season totals
  last_7_ip = 0
  last_7_bb = 0
  last_7_h = 0
  last_7_r = 0
  last_7_er = 0
  last_7_so = 0
  last_30_ip = 0
  last_30_bb = 0
  last_30_h = 0
  last_30_r = 0
  last_30_er = 0
  last_30_so = 0
  season_ip = 0
  season_bb = 0
  season_h = 0
  season_r = 0
  season_er = 0
  season_so = 0
  i = 1
  gamelog_final.reverse.map do |game|
    if game["Game"].present?
      if i == 1
        last_5["score"] = game["Score"].to_s
        last_5["opponent"] = game["Opponent"].to_s
        last_5["game"] = game["Date"].to_s
        last_5["ip"] = game["IP"].to_s
        last_5["r"] = game["R"].to_s
        last_5["er"] = game["ER"].to_s
        last_5["h"] = game["H"].to_s
        last_5["bb"] = game["BB"].to_s
        last_5["so"] = game["SO"].to_s
        game["DEC"].to_s.length > 0 ? last_5["dec"] = game["DEC"].to_s : last_5["dec"] = "ND"
        last_5["era"] = ("%.2f" % (9 * game["ER"].to_f / (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.333333)))).to_s
        last_5["whip"] = ("%.2f" % ((game["H"].to_f + game["BB"].to_f)/ (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.333333)))).to_s
        last_5["war"] = "--"
      end

      if i == 2
        last_4["score"] = game["Score"].to_s
        last_4["opponent"] = game["Opponent"].to_s
        last_4["game"] = game["Date"].to_s
        last_4["ip"] = game["IP"].to_s
        last_4["r"] = game["R"].to_s
        last_4["er"] = game["ER"].to_s
        last_4["h"] = game["H"].to_s
        last_4["bb"] = game["BB"].to_s
        last_4["so"] = game["SO"].to_s
        game["DEC"].to_s.length > 0 ? last_4["dec"] = game["DEC"].to_s : last_4["dec"] = "ND"
        last_4["era"] = ("%.2f" % (9 * game["ER"].to_f / (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.333333)))).to_s
        last_4["whip"] = ("%.2f" % ((game["H"].to_f + game["BB"].to_f)/ (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.333333)))).to_s
        last_4["war"] = "--"
      end

      if i == 3
        last_3["score"] = game["Score"].to_s
        last_3["opponent"] = game["Opponent"].to_s
        last_3["game"] = game["Date"].to_s
        last_3["ip"] = game["IP"].to_s
        last_3["r"] = game["R"].to_s
        last_3["er"] = game["ER"].to_s
        last_3["h"] = game["H"].to_s
        last_3["bb"] = game["BB"].to_s
        last_3["so"] = game["SO"].to_s
        game["DEC"].to_s.length > 0 ? last_3["dec"] = game["DEC"].to_s : last_3["dec"] = "ND"
        last_3["era"] = ("%.2f" % (9 * game["ER"].to_f / (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.333333)))).to_s
        last_3["whip"] = ("%.2f" % ((game["H"].to_f + game["BB"].to_f)/ (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.333333)))).to_s
        last_3["war"] = "--"
      end

      if i == 4
        last_2["score"] = game["Score"].to_s
        last_2["opponent"] = game["Opponent"].to_s
        last_2["game"] = game["Date"].to_s
        last_2["ip"] = game["IP"].to_s
        last_2["r"] = game["R"].to_s
        last_2["er"] = game["ER"].to_s
        last_2["h"] = game["H"].to_s
        last_2["bb"] = game["BB"].to_s
        last_2["so"] = game["SO"].to_s
        game["DEC"].to_s.length > 0 ? last_2["dec"] = game["DEC"].to_s : last_2["dec"] = "ND"
        last_2["era"] = ("%.2f" % (9 * game["ER"].to_f / (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.333333)))).to_s
        last_2["whip"] = ("%.2f" % ((game["H"].to_f + game["BB"].to_f)/ (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.333333)))).to_s
        last_2["war"] = "--"
      end

      if i == 5
        last_1["score"] = game["Score"].to_s
        last_1["opponent"] = game["Opponent"].to_s
        last_1["game"] = game["Date"].to_s
        last_1["ip"] = game["IP"].to_s
        last_1["r"] = game["R"].to_s
        last_1["er"] = game["ER"].to_s
        last_1["h"] = game["H"].to_s
        last_1["bb"] = game["BB"].to_s
        last_1["so"] = game["SO"].to_s
        game["DEC"].to_s.length > 0 ? last_1["dec"] = game["DEC"].to_s : last_1["dec"] = "ND"
        last_1["era"] = ("%.2f" % (9 * game["ER"].to_f / (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.333333)))).to_s
        last_1["whip"] = ("%.2f" % ((game["H"].to_f + game["BB"].to_f)/ (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.333333)))).to_s
        last_1["war"] = "--"
      end

      if i <= 7
        last_7_bb += game["BB"].to_i
        last_7_h += game["H"].to_i
        last_7_r += game["R"].to_i
        last_7_er += game["ER"].to_i
        last_7_ip += (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.3333333))
        last_7_so += game["SO"].to_i
      end

      if i <= 30
        last_30_bb += game["BB"].to_i
        last_30_h += game["H"].to_i
        last_30_r += game["R"].to_i
        last_30_er += game["ER"].to_i
        last_30_ip += (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.3333333))
        last_30_so += game["SO"].to_i
      end

      season_bb += game["BB"].to_i
      season_h += game["H"].to_i
      season_r += game["R"].to_i
      season_er += game["ER"].to_i
      season_ip += (game["IP"].to_i + ((game["IP"].to_f % 1) * 3.3333333))
      season_so += game["SO"].to_i
      i += 1
    end
  end

  # Fill out hashes
  last_7["bb"] = last_7_bb.to_s
  last_7["h"] = last_7_h.to_s
  last_7["ip"] = last_7_ip.to_s
  last_7["r"] = last_7_r.to_s
  last_7["er"] = last_7_er.to_s
  last_7["so"] = last_7_so.to_s
  last_7["era"] = ("%.2f" % (9 * last_7_er / last_7_ip)).to_s
  last_7["whip"] = ("%.2f" % ((last_7_bb + last_7_h) / last_7_ip)).to_s
  last_7["war"] = "--"
  last_30["bb"] = last_30_bb.to_s
  last_30["h"] = last_30_h.to_s
  last_30["ip"] = last_30_ip.to_s
  last_30["r"] = last_30_r.to_s
  last_30["er"] = last_30_er.to_s
  last_30["so"] = last_30_so.to_s
  last_30["era"] = ("%.2f" % (9 * last_30_er / last_30_ip)).to_s
  last_30["whip"] = ("%.2f" % ((last_30_bb + last_30_h) / last_30_ip)).to_s
  last_30["war"] = "--"
  season["bb"] = season_bb.to_s
  season["h"] = season_h.to_s
  season["ip"] = season_ip.to_s
  season["r"] = season_r.to_s
  season["er"] = season_er.to_s
  season["so"] = season_so.to_s
  season["era"] = ("%.2f" % (9 * season_er / season_ip)).to_s
  season["whip"] = ("%.2f" % ((season_bb + season_h) / season_ip)).to_s
  season["war"] = find_player_war(war_url, position)

  # Fix IP
  last_7["ip"] = ("%.1f" % (last_7["ip"].to_i + ((last_7["ip"].to_f % 1) / 3.33333333))).to_s
  last_30["ip"] = ("%.1f" % (last_30["ip"].to_i + ((last_30["ip"].to_f % 1) / 3.33333333))).to_s
  season["ip"] = ("%.1f" % (season["ip"].to_i + ((season["ip"].to_f % 1) / 3.33333333))).to_s

  # create gamelog
  stat_gamelog = Hash.new
  stat_gamelog["player"] = player_name
  stat_gamelog["position"] = "pitcher"
  stat_gamelog["stat"] = stat
  i = 0
  if last_1
    stat_gamelog["game1"] = last_5
    i += 1
  end
  if last_2
    stat_gamelog["game1"] = last_4
    stat_gamelog["game2"] = last_5
    i += 1
  end
  if last_3
    stat_gamelog["game1"] = last_3
    stat_gamelog["game2"] = last_4
    stat_gamelog["game3"] = last_5
    i += 1
  end
  if last_4
    stat_gamelog["game1"] = last_2
    stat_gamelog["game2"] = last_3
    stat_gamelog["game3"] = last_4
    stat_gamelog["game4"] = last_5
    i += 1
  end
  if last_5
    stat_gamelog["game1"] = last_1
    stat_gamelog["game2"] = last_2
    stat_gamelog["game3"] = last_3
    stat_gamelog["game4"] = last_4
    stat_gamelog["game5"] = last_5
    i += 1
  end

  stat_gamelog["last_seven"] = last_7
  stat_gamelog["last_thirty"] = last_30
  stat_gamelog["season"] = season
  stat_gamelog["game_count"] = i

  resp = client.update_item({
                                table_name: '5_Stat_MLB',
                                key: {
                                    "User" => user,
                                    "Year" => 2016
                                },
                                attribute_updates: {
                                    stat_string + "_value" => {
                                        value: season[stat.downcase].to_f.round(2),
                                        action: "PUT"
                                    },
                                    stat_string + "_gamelog" => {
                                        value: stat_gamelog,
                                        action: "PUT"
                                    }
                                }
                            })
end

def find_player_war(player_war_url, position)
  war_row = -1
  war = 0

  doc = Nokogiri::HTML(open(player_war_url))

  if position == 'field'
    table_id = "batting_value"
  else
    table_id = "pitching_value"
  end

  # find the columns of the stats
  doc.css('#' + table_id + " thead").each do |thead|
    i = 0
    thead.css("th").each do |th|
      if th["data-stat"].downcase == 'war_pitch' || th["data-stat"].downcase == 'war'
        war_row = i
      end
      i += 1
    end
  end


  # loop through war table
  doc.css('#' + table_id + " tr").each do |tr|
    if tr.attribute('id').to_s == "#{table_id}.2015"
      i = 0
      tr.css('td').each do |td|
        if i == war_row
          war = td.text
        end
        i += 1
      end
    end
  end

  return war
end