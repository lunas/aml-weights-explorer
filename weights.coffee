
$ ->
  ##################### Tangle

  tangle = new Tangle(document.getElementById("weights-ui"), {
    initialize: ()->

      this.fatf = 46.15
      this.fin_secrecy = 38.46
      this.us_incsr = 15.38

      this.ti_cpi = 100

      this.business_disclosure = 12.5
      this.auditing_std = 37.5
      this.security_exchange = 37.5
      this.fin_sector = 12.5

      this.open_budget = 33.33
      this.transpar_account_corr = 33.33
      this.political_disclosure = 33.33

      this.instit_strength = 33.33
      this.rule_of_law = 33.33
      this.freedom_house = 33.33

      this.ml_tf_cat = 65
      this.corruption_risk_cat = 10
      this.fin_transpar_std_cat = 15
      this.public_transpar_account_cat = 5
      this.political_legal_risk_cat = 5

      this.fatf_osc = this.fatf * this.ml_tf_cat / 100
      this.fin_secrecy_osc = this.fin_secrecy * this.ml_tf_cat / 100
      this.us_incsr_osc = this.us_incsr * this.ml_tf_cat / 100

      this.ti_cpi_osc = this.ti_cpi * this.corruption_risk_cat / 100

      this.business_disclosure_osc = this.business_disclosure * this.fin_transpar_std_cat / 100
      this.auditing_std_osc = this.auditing_std * this.fin_transpar_std_cat / 100
      this.security_exchange_osc = this.security_exchange * this.fin_transpar_std_cat / 100
      this.fin_sector_osc = this.fin_sector * this.fin_transpar_std_cat / 100

      this.open_budget_osc = this.open_budget * this.public_transpar_account_cat / 100
      this.transpar_account_corr_osc = this.transpar_account_corr * this.public_transpar_account_cat / 100
      this.political_disclosure_osc = this.political_disclosure * this.public_transpar_account_cat / 100

      this.instit_strength_osc = this.instit_strength * this.political_legal_risk_cat / 100
      this.rule_of_law_osc = this.rule_of_law * this.political_legal_risk_cat / 100
      this.freedom_house_osc = this.freedom_house * this.political_legal_risk_cat / 100

    update: ()->

  })

  ##################### D3
  d3.csv "aml.csv", (error, data) ->
    if error
      console.log(error)
      return

    render_ranking(data)
    render_scatterplot(data)


  render_ranking = (aml) ->
    list = d3.select('.ranking').append('table')
    list.selectAll('tr')
      .data(aml)
      .enter()
      .append('tr')
      .html (row)->
        s = '<td>' + row.country + '</td>'
        s += '<td>' + d3.round(row["OVERALL.SCORE"], 2) + '</td>'


  render_scatterplot = (aml) ->
