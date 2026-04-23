const cheerio = require('cheerio')
const dayjs = require('dayjs')
const utc = require('dayjs/plugin/utc')
const timezone = require('dayjs/plugin/timezone')
const customParseFormat = require('dayjs/plugin/customParseFormat')

dayjs.extend(utc)
dayjs.extend(timezone)
dayjs.extend(customParseFormat)

const TZ = 'America/St_Johns'

module.exports = {
    site: 'ntv.ca',
    days: 7,
    url: 'https://ntv.ca/wp-admin/admin-ajax.php',
    request: {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'X-Requested-With': 'XMLHttpRequest',
            'User-Agent':
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Origin': 'https://ntv.ca',
            'Referer': 'https://ntv.ca/schedules'
        },
        data({ channel, date }) {
            const dayMidnight = dayjs.tz(date.format('YYYY-MM-DD'), TZ).startOf('day')
            const params = new URLSearchParams()
            params.append('action', 'extvs_get_schedule_simple')
            params.append(
                'param_shortcode',
                JSON.stringify({
                    style: '2',
                    fullcontent_in: 'none',
                    show_image: 'none',
                    channel: '',
                    slidesshow: '7',
                    slidesscroll: '',
                    start_on: '',
                    before_today: '0',
                    after_today: '7',
                    list_dates: '',
                    order: 'ASC',
                    orderby: 'date',
                    meta_key: '',
                    meta_value: '',
                    order_channel: '',
                    class: '',
                    ID: 'ex-4005'
                })
            )
            params.append('date', String(dayMidnight.unix()))
            params.append('chanel', channel.site_id)
            return params
        }
    },
    parser({ content, date }) {
        const programs = []
        if (!content) return programs

        let payload
        try {
            payload = typeof content === 'string' ? JSON.parse(content) : content
        } catch (err) {
            return programs
        }

        if (!payload || !payload.html) return programs

        const $ = cheerio.load(payload.html)
        const dayStart = dayjs.tz(date.format('YYYY-MM-DD'), TZ).startOf('day')

        const entries = []
        $('tr').each((_, tr) => {
            const time = $(tr).find('td.extvs-table1-time span').first().text().trim()
            const title = $(tr).find('td.extvs-table1-programme h3').first().text().trim()
            if (!time || !title) return
            const start = dayjs.tz(
                `${dayStart.format('YYYY-MM-DD')} ${time}`,
                'YYYY-MM-DD h:mm a',
                TZ
            )
            entries.push({ start, title })
        })

        for (let i = 0; i < entries.length; i++) {
            const { start, title } = entries[i]
            const stop =
                i + 1 < entries.length ? entries[i + 1].start : dayStart.add(1, 'day')
            programs.push({ title, start, stop })
        }

        return programs
    }
}
