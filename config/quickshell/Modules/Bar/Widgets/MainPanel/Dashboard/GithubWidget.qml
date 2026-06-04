import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Card {
    id: root

    property string username: GithubConfig.username
    property int publicRepos: 0
    property int privateRepos: 0
    property int followers: 0
    property int totalStars: 0
    property int totalForks: 0
    property string topRepoName: "..."
    property int topRepoStars: 0
    property string topLanguage: "..."
    property string joinedDate: "..."
    property int totalCommits: 0
    readonly property bool hasToken: GithubConfig.token !== ""

    clip: true

    Process {
        id: fetchProfile

        command: root.hasToken ? ["curl", "-s", "-H", "Authorization: token " + GithubConfig.token, "https://api.github.com/user"] : ["curl", "-s", "https://api.github.com/users/" + root.username]
        running: root.username !== ""
        onExited: (code) => {
            if (code === 0) {
                try {
                    const profile = JSON.parse(profileOutput.text);
                    if (profile) {
                        root.publicRepos = profile.public_repos || 0;
                        if (root.hasToken)
                            root.privateRepos = profile.total_private_repos || profile.owned_private_repos || 0;

                        root.followers = profile.followers || 0;
                        if (profile.created_at) {
                            let date = new Date(profile.created_at);
                            let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                            root.joinedDate = months[date.getMonth()] + " " + date.getFullYear();
                        }
                    }
                } catch (e) {
                }
            }
        }

        stdout: StdioCollector {
            id: profileOutput
        }

    }

    Process {
        id: fetchRepos

        command: root.hasToken ? ["curl", "-s", "-H", "Authorization: token " + GithubConfig.token, "https://api.github.com/user/repos?per_page=100&type=owner"] : ["curl", "-s", "https://api.github.com/users/" + root.username + "/repos?per_page=100"]
        running: root.username !== ""
        onExited: (code) => {
            if (code === 0) {
                try {
                    const repos = JSON.parse(reposOutput.text);
                    if (Array.isArray(repos)) {
                        let starsSum = 0;
                        let forksSum = 0;
                        let maxStars = -1;
                        let bestRepoName = "";
                        let langCounts = {
                        };
                        for (let i = 0; i < repos.length; i++) {
                            let r = repos[i];
                            if (!r)
                                continue;

                            starsSum += r.stargazers_count || 0;
                            forksSum += r.forks_count || 0;
                            if (r.stargazers_count > maxStars) {
                                maxStars = r.stargazers_count;
                                bestRepoName = r.name;
                            }
                            if (r.language)
                                langCounts[r.language] = (langCounts[r.language] || 0) + 1;

                        }
                        root.totalStars = starsSum;
                        root.totalForks = forksSum;
                        root.topRepoName = bestRepoName || "None";
                        root.topRepoStars = maxStars > 0 ? maxStars : 0;
                        let mostLang = "None";
                        let maxLangCount = 0;
                        for (let lang in langCounts) {
                            if (langCounts[lang] > maxLangCount) {
                                maxLangCount = langCounts[lang];
                                mostLang = lang;
                            }
                        }
                        root.topLanguage = mostLang;
                    }
                } catch (e) {
                }
            }
        }

        stdout: StdioCollector {
            id: reposOutput
        }

    }

    Process {
        id: fetchTotalCommits

        command: ["curl", "-s", "-H", "Authorization: token " + GithubConfig.token, "https://api.github.com/search/commits?q=author:" + root.username]
        running: root.hasToken && root.username !== ""
        onExited: (code) => {
            if (code === 0) {
                try {
                    const search = JSON.parse(commitsOutput.text);
                    if (search && search.total_count !== undefined)
                        root.totalCommits = search.total_count;

                } catch (e) {
                }
            }
        }

        stdout: StdioCollector {
            id: commitsOutput
        }

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Constants.sizeLg
        spacing: Constants.sizeSm
        visible: root.username !== ""

        ThemedText {
            text: "GitHub Stats"
            color: Theme.purple
            font.pixelSize: Constants.sizeSm + 1
            font.weight: Font.Bold
        }

        RowLayout {
            spacing: Constants.sizeLg
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                spacing: 6

                GithubWidgetStat {
                    icon: ""
                    iconColor: Theme.yellow
                    category: "Stars:"
                    value: root.totalStars
                }

                GithubWidgetStat {
                    icon: ""
                    iconColor: Theme.cyan
                    category: "Forks:"
                    value: root.totalForks
                }

                GithubWidgetStat {
                    icon: ""
                    iconColor: Theme.purple
                    category: "Followers:"
                    value: root.followers
                }

                GithubWidgetStat {
                    icon: ""
                    iconColor: Theme.blue
                    category: "Lang:"
                    value: root.topLanguage
                }

            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: Theme.border
                opacity: 0.5
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                spacing: 6

                GithubWidgetStat {
                    icon: ""
                    iconColor: Theme.pink
                    category: root.hasToken ? "Public:" : "Repos:"
                    value: root.publicRepos
                }

                GithubWidgetStat {
                    visible: root.hasToken
                    icon: ""
                    iconColor: Theme.red
                    category: "Private:"
                    value: root.privateRepos
                }

                GithubWidgetStat {
                    visible: root.hasToken
                    icon: ""
                    iconColor: Theme.orange
                    category: "Commits:"
                    value: root.totalCommits
                }

                GithubWidgetStat {
                    icon: "󰸗"
                    iconColor: Theme.green
                    category: "Joined:"
                    value: root.joinedDate
                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
            opacity: 0.5
        }

        GithubWidgetStat {
            icon: "󰓎"
            iconColor: Theme.yellow
            category: "Top:"
            value: root.topRepoName.replace(/^.*\//, "") + " (" + root.topRepoStars + " ⭐)"
        }

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Constants.sizeLg
        visible: root.username === ""
        spacing: Constants.sizeSm

        ThemedText {
            text: "GitHub Stats"
            color: Theme.purple
            font.pixelSize: Constants.sizeSm + 1
            font.weight: Font.Bold
        }

        Item {
            Layout.fillHeight: true
        }

        ThemedText {
            text: "⚠️ Username Required"
            color: Theme.red
            font.pixelSize: Constants.sizeSm
            font.weight: Font.Bold
            Layout.alignment: Qt.AlignHCenter
        }

        ThemedText {
            text: "Configure your username in\nCore/GithubConfig.qml"
            color: Theme.muted
            font.pixelSize: Constants.sizeSm - 1
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.fillHeight: true
        }

    }

    Timer {
        interval: 600000
        running: root.username !== ""
        repeat: true
        onTriggered: {
            fetchProfile.running = true;
            fetchRepos.running = true;
            if (root.hasToken)
                fetchTotalCommits.running = true;

        }
    }

    component GithubWidgetStat: RowLayout {
        property string icon
        property color iconColor: Theme.fg
        property string category
        property string value

        spacing: Constants.sizeXs

        ThemedText {
            text: icon
            color: iconColor
            font.pixelSize: Constants.sizeSm - 1
        }

        ThemedText {
            text: category
            color: Theme.muted
            font.pixelSize: Constants.sizeSm - 1
        }

        ThemedText {
            text: String(value)
            color: Theme.fg
            font.pixelSize: Constants.sizeSm - 1
            font.weight: Font.Medium
            Layout.fillWidth: true
        }

    }

}
