//
//  ContentView.swift
//  SantosLaguna
//
//  App informativa del Club Santos Laguna (Torreón, Coahuila).
//  Se navega con los botones del menú o deslizando a la izquierda / derecha.
//

import SwiftUI
import MapKit

// MARK: - Colores del club
extension Color {
    static let santosVerde = Color(red: 0.0, green: 0.52, blue: 0.24)
    static let santosVerdeOscuro = Color(red: 0.0, green: 0.36, blue: 0.17)
    static let santosDorado = Color(red: 0.96, green: 0.73, blue: 0.13)
}

// MARK: - Orden de las pantallas
enum Pantalla: Int, CaseIterable {
    case principal = 0
    case historia
    case campeonatos
    case estadio
    case ubicacion
    case cantera

    var titulo: String {
        switch self {
        case .principal:   return "Santos Laguna"
        case .historia:    return "Historia"
        case .campeonatos: return "Campeonatos"
        case .estadio:     return "Estadio"
        case .ubicacion:   return "Ubicación"
        case .cantera:     return "Cantera"
        }
    }

    var simbolo: String {
        switch self {
        case .principal:   return "house.fill"
        case .historia:    return "book.closed"
        case .campeonatos: return "trophy.fill"
        case .estadio:     return "sportscourt.fill"
        case .ubicacion:   return "map"
        case .cantera:     return "figure.soccer"
        }
    }
}

// MARK: - Vista principal
struct ContentView: View {
    @State private var pantallaActual: Pantalla = .principal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        contenidoActual
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .id(pantallaActual) // regresa el scroll arriba al cambiar
                }

                indicaciones

                if pantallaActual != .principal {
                    Button {
                        cambiarPantalla(a: .principal)
                    } label: {
                        Label("Regresar a página principal", systemImage: "house.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.santosVerde)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.santosVerde.opacity(0.06))
            .navigationTitle(pantallaActual.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.santosVerde, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .contentShape(Rectangle())
            .simultaneousGesture(gestoSwipe)
        }
        .tint(.santosVerde)
    }

    // Contenido según la pantalla actual
    @ViewBuilder
    private var contenidoActual: some View {
        switch pantallaActual {
        case .principal:   pantallaPrincipal
        case .historia:    HistoriaView()
        case .campeonatos: CampeonatosView()
        case .estadio:     EstadioView()
        case .ubicacion:   UbicacionView()
        case .cantera:     CanteraView()
        }
    }

    // MARK: Pantalla principal
    private var pantallaPrincipal: some View {
        VStack(spacing: 18) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .shadow(radius: 4)

            Text("Club Santos Laguna")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(Color.santosVerdeOscuro)
                .multilineTextAlignment(.center)

            Text("Los Guerreros de Torreón, Coahuila")
                .foregroundStyle(.secondary)

            Image("campeones")
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(alignment: .bottomLeading) {
                    Text("Campeones Clausura 2018")
                        .font(.caption.bold())
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(10)
                }

            Text("Selecciona una sección o desliza hacia la izquierda")
                .font(.headline)
                .multilineTextAlignment(.center)

            botonMenu(.historia, color: .santosVerde)
            botonMenu(.campeonatos, color: .orange)
            botonMenu(.estadio, color: .santosVerdeOscuro)
            botonMenu(.ubicacion, color: .blue)
            botonMenu(.cantera, color: .purple)
        }
    }

    private func botonMenu(_ destino: Pantalla, color: Color) -> some View {
        Button {
            cambiarPantalla(a: destino)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: destino.simbolo)
                    .font(.title2)
                    .frame(width: 30)
                Text(destino.titulo)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: Indicaciones inferiores
    private var indicaciones: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(Pantalla.allCases, id: \.self) { p in
                    Circle()
                        .fill(p == pantallaActual ? Color.santosVerde : Color.gray.opacity(0.35))
                        .frame(width: 8, height: 8)
                }
            }

            Text("Pantalla \(pantallaActual.rawValue + 1) de \(Pantalla.allCases.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .top) {
                if let anterior = Pantalla(rawValue: pantallaActual.rawValue - 1) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                        Text("Derecha: \(anterior.titulo)")
                    }
                }
                Spacer(minLength: 12)
                if let siguiente = Pantalla(rawValue: pantallaActual.rawValue + 1) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                        Text("Izquierda: \(siguiente.titulo)")
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(Color.santosVerde)
            .multilineTextAlignment(.center)
        }
        .padding()
        .background(.bar)
    }

    // MARK: Gesto de swipe
    private var gestoSwipe: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { valor in
                let horizontal = valor.translation.width
                let vertical = valor.translation.height

                // Solo movimientos horizontales claros
                guard abs(horizontal) >= 60, abs(horizontal) > abs(vertical) else { return }

                let paso = horizontal < 0 ? 1 : -1
                guard let destino = Pantalla(rawValue: pantallaActual.rawValue + paso) else { return }
                cambiarPantalla(a: destino)
            }
    }

    private func cambiarPantalla(a destino: Pantalla) {
        withAnimation(.easeInOut(duration: 0.25)) {
            pantallaActual = destino
        }
    }
}

// MARK: - Componentes reutilizables
struct Encabezado: View {
    let titulo: String
    let simbolo: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: simbolo)
                .font(.system(size: 54))
                .foregroundStyle(Color.santosVerde)
            Text(titulo)
                .font(.title)
                .bold()
        }
        .frame(maxWidth: .infinity)
    }
}

struct Tarjeta: View {
    let titulo: String
    let texto: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo)
                .font(.headline)
                .foregroundStyle(Color.santosVerdeOscuro)
            Text(texto)
                .font(.body)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}

struct FotoSeccion: View {
    let nombre: String
    var alto: CGFloat = 200

    var body: some View {
        Image(nombre)
            .resizable()
            .scaledToFill()
            .frame(height: alto)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Historia
struct HistoriaView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Encabezado(titulo: "Historia", simbolo: "book.closed")
            FotoSeccion(nombre: "logoFondo", alto: 240)

            Tarjeta(titulo: "Fundación",
                    texto: "El Club Santos Laguna fue fundado el 4 de septiembre de 1983 en Torreón, Coahuila, para representar a toda la Comarca Lagunera.")
            Tarjeta(titulo: "Llegada a Primera División",
                    texto: "En 1988 el club llegó a la Primera División del fútbol mexicano y desde entonces se ha consolidado como uno de los equipos más ganadores de las últimas décadas.")
            Tarjeta(titulo: "Identidad",
                    texto: "Sus colores son el verde y el blanco, por eso se les conoce como los Albiverdes. Su apodo más famoso es Los Guerreros, y su escudo muestra una corona dorada y seis estrellas, una por cada campeonato de liga.")
        }
    }
}

// MARK: - Campeonatos
struct CampeonatosView: View {
    private let ligas = [
        "Invierno 1996",
        "Verano 2001",
        "Apertura 2008",
        "Clausura 2012",
        "Clausura 2015",
        "Clausura 2018"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Encabezado(titulo: "Campeonatos", simbolo: "trophy.fill")
            FotoSeccion(nombre: "campeones", alto: 240)

            Text("Títulos de Liga")
                .font(.title3).bold()

            ForEach(Array(ligas.enumerated()), id: \.offset) { indice, torneo in
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.santosDorado)
                    Text(torneo)
                        .font(.headline)
                    Spacer()
                    Text("#\(indice + 1)")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Tarjeta(titulo: "Otros títulos",
                    texto: "Copa MX (Apertura 2014) y Campeón de Campeones (2015).")
        }
    }
}

// MARK: - Estadio
struct EstadioView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Encabezado(titulo: "Estadio Corona", simbolo: "sportscourt.fill")
            FotoSeccion(nombre: "estadioExterior")
            FotoSeccion(nombre: "estadio")

            Tarjeta(titulo: "La casa de los Guerreros",
                    texto: "El Estadio Corona, también conocido como TSM (Territorio Santos Modelo), fue inaugurado el 11 de noviembre de 2009 con un partido entre Santos Laguna y el Santos de Brasil.")
            Tarjeta(titulo: "Capacidad",
                    texto: "Tiene capacidad para alrededor de 30,000 aficionados. Sus butacas verdes y su fachada metálica lo convierten en uno de los estadios más modernos de México.")
            Tarjeta(titulo: "El antiguo Estadio Corona",
                    texto: "Antes de 2009 el equipo jugaba en el antiguo Estadio Corona, inaugurado en 1970, donde el club ganó sus primeros campeonatos.")
        }
    }
}

// MARK: - Ubicación
struct UbicacionView: View {
    // Estadio Corona (TSM), Torreón, Coahuila
    private let coordenada = CLLocationCoordinate2D(latitude: 25.6289, longitude: -103.3789)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Encabezado(titulo: "¿Dónde juega Santos?", simbolo: "map")

            Text("Estadio Corona, Torreón, Coahuila, México")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Map(
                initialPosition: .region(
                    MKCoordinateRegion(
                        center: coordenada,
                        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                    )
                ),
                interactionModes: [] // fijo para no interferir con el swipe
            ) {
                Marker("Estadio Corona", systemImage: "soccerball", coordinate: coordenada)
                    .tint(Color.santosVerde)
            }
            .frame(height: 340)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Tarjeta(titulo: "Torreón",
                    texto: "Torreón, la \"capital mundial de la plata\", forma parte de la Comarca Lagunera junto con Gómez Palacio y Lerdo, Durango.")
        }
    }
}

// MARK: - Cantera
struct CanteraView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Encabezado(titulo: "Cantera", simbolo: "figure.soccer")
            FotoSeccion(nombre: "cantera", alto: 220)

            Tarjeta(titulo: "Fuerzas básicas",
                    texto: "Santos Laguna es reconocido por formar jugadores en sus fuerzas básicas, muchos de los cuales han llegado al primer equipo y a la Selección Mexicana.")
            Tarjeta(titulo: "Santos Femenil",
                    texto: "Desde 2017 el club también participa en la Liga MX Femenil, impulsando el talento de las jugadoras de la región.")
            Tarjeta(titulo: "Afición",
                    texto: "La afición lagunera llena el estadio de verde y blanco en cada partido y acompaña al equipo como uno de sus mayores orgullos.")
        }
    }
}

#Preview {
    ContentView()
}
