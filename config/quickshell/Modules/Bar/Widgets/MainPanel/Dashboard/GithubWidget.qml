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
                    console.log("Error parsing GitHub profile data:", e);
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
                    console.log("Error parsing GitHub repos data:", e);
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
                    console.log("Error parsing GitHub commits data:", e);
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

                RowLayout {
                    spacing: Constants.sizeXs

                    ThemedText {
                        text: ""
                        color: Theme.yellow
                        font.pixelSize: Constants.sizeSm - 1
                    }

                    ThemedText {
                        text: "Stars:"
                        color: Theme.muted
                        font.pixelSize: Constants.sizeSm - 1
                    }

                    ThemedText {
                        text: String(root.totalStars)
                        color: Theme.fg
                        font.pixelSize: Constants.sizeSm - 1
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    spacing: Constants.sizeXs

                    ThemedText {
                        text: ""
                        color: Theme.cyan
                        font.pixelSize: Constants.sizeSm
                    }

                    ThemedText {
                        text: "Forks:"
                        color: Theme.muted
                        font.pixelSize: Constants.sizeSm - 1
                    }

                    ThemedText {
                        text: String(root.totalForks)
                        color: Theme.fg
                        font.pixelSize: Constants.sizeSm - 1
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    spacing: Constants.sizeXs

                    ThemedText {
                        text: ""
                        color: Theme.purple
                        font.pixelSize: Constants.sizeSm
                    }

                    ThemedText {
                        text: "Followers:"
                        color: Theme.muted
                        font.pixelSize: Constants.sizeSm - 1
                    }

                    ThemedText {
                        text: String(root.followers)
                        color: Theme.fg
                        font.pixelSize: Constants.sizeSm - 1
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    spacing: Constants.sizeXs
                    Layout.fillWidth: true

                    ThemedText {
                        text: ""
                        color: Theme.blue
                        font.pixelSize: Constants.sizeSm
                    }

                    ThemedText {
                        text: "Lang:"
                        color: Theme.muted
                        font.pixelSize: Constants.sizeSm - 1
                    }

                    ThemedText {
                        text: root.topLanguage
                        color: Theme.fg
                        font.pixelSize: Constants.sizeSm - 1
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

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

                RowLayout {
                    spacing: Constants.sizeXs

                    ThemedText {
                        text: ""
                        color: Theme.purple
                        font.pixelSize: Constants.sizeSm
                    }

                    ThemedText {
                        text: root.hasToken ? "Public:" : "Repos:"
                        color: Theme.muted
                        font.pixelSize: Constants.sizeSm - 1
                    }

                    ThemedText {
                        text: String(root.publicRepos)
                        color: Theme.fg
                        font.pixelSize: Constants.sizeSm - 1
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    spacing: Constants.sizeXs
                    visible: root.hasToken

                    ThemedText {
                        text: ""
                        color: Theme.red
                        font.pixelSize: Constants.sizeSm - 1
                    }

                    ThemedText {
                        text: "Private:"
                        color: Theme.muted
                        font.pixelSize: Constants.sizeSm - 1
                    }

                    ThemedText {
                        text: String(root.privateRepos)
                        color: Theme.fg
                        font.pixelSize: Constants.sizeSm - 1
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    spacing: Constants.sizeXs
                    visible: root.hasToken

                    ThemedText {
                        text: ""
                        color: Theme.fg
                        font.pixelSize: Constants.sizeSm
                    }

                    ThemedText {
                        text: "Commits:"
                        color: Theme.muted
                        font.pixelSize: Constants.sizeSm - 1
                    }

                    ThemedText {
                        text: String(root.totalCommits)
                        color: Theme.fg
                        font.pixelSize: Constants.sizeSm - 1
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    spacing: Constants.sizeXs

                    ThemedText {
                        text: "󰸗"
                        color: Theme.green
                        font.pixelSize: Constants.sizeSm
                    }

                    ThemedText {
                        text: "Joined:"
                        color: Theme.muted
                        font.pixelSize: Constants.sizeSm - 1
                    }

                    ThemedText {
                        text: root.joinedDate
                        color: Theme.fg
                        font.pixelSize: Constants.sizeSm - 1
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }

                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
            opacity: 0.5
        }

        RowLayout {
            spacing: Constants.sizeXs
            Layout.fillWidth: true

            ThemedText {
                text: "󰓎"
                color: Theme.yellow
                font.pixelSize: Constants.sizeSm
            }

            ThemedText {
                text: "Top:"
                color: Theme.muted
                font.pixelSize: Constants.sizeSm - 1
            }

            ThemedText {
                text: root.topRepoName.replace(/^.*\//, "") + " (" + root.topRepoStars + " ⭐)"
                color: Theme.fg
                font.pixelSize: Constants.sizeSm - 1
                font.weight: Font.Bold
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

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

}
