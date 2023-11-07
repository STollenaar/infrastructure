kubectl port-forward svc/jellyseerr 5055:5055 &>/dev/null &
kubectl port-forward svc/radarr 7878:7878 &>/dev/null &
kubectl port-forward svc/sonarr 8989:8989 &>/dev/null &
kubectl port-forward svc/prowlarr 9696:9696 &>/dev/null &
kubectl port-forward svc/jellyfin-web 8096:8096 &>/dev/null &
kubectl port-forward svc/qbittorrent 8080:8080 8000:8000 &>/dev/null &
